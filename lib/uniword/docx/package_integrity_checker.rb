# frozen_string_literal: true

require "nokogiri"
require "set"

module Uniword
  module Docx
    # Write-time OPC package integrity gate.
    #
    # Pure, non-mutating checker invoked on the in-memory ZIP content hash
    # after reconciliation and relationship injection, before ZipPackager.
    # MECE with the mutating Reconciler: the Reconciler repairs what it can,
    # this checker refuses output that would produce an invalid package.
    #
    # Issue codes mirror the post-hoc OpcValidator semantics
    # (lib/uniword/validation/opc_validator.rb) where they match:
    # - OPC-005: every ZIP entry has a content type (Default or Override)
    # - OPC-006: every relationship target resolves to a package entry
    # - OPC-008: every emitted XML part is well-formed
    # Codes introduced by the write-time gate:
    # - OPC-009: every r:id/r:embed/r:link reference in any XML part
    #   resolves to a Relationship in that part's .rels
    # - OPC-010: relationship IDs are unique within every .rels part
    #
    # @example Check an in-memory content hash
    #   issues = PackageIntegrityChecker.new.check(zip_content)
    #   issues.each { |i| puts "#{i.code} [#{i.part}] #{i.message}" }
    class PackageIntegrityChecker
      # Package relationships part namespace (OPC).
      RELS_NS = "http://schemas.openxmlformats.org/package/2006/relationships"

      # Office document relationship attribute namespace (r:id, r:embed...).
      OFFICE_RELS_NS =
        "http://schemas.openxmlformats.org/officeDocument/2006/relationships"

      # [Content_Types].xml namespace.
      CT_NS = "http://schemas.openxmlformats.org/package/2006/content-types"

      # Relationship attribute local names that reference rIds.
      R_REF_ATTRIBUTES = %w[id embed link].freeze

      # Check an in-memory package content hash against every invariant.
      #
      # One issue-collector pass; never mutates the content hash.
      #
      # @param content [Hash{String => String}] ZIP entry path => content
      # @return [Array<Validation::Report::ValidationIssue>] Issues found
      #   (empty when the package is valid)
      def check(content)
        @content = content
        @issues = []
        @parsed_parts = {}

        parse_all_parts # OPC-008, memoizes documents for later checks
        check_content_type_coverage # OPC-005
        check_relationship_targets # OPC-006
        check_relationship_references # OPC-009
        check_rid_uniqueness # OPC-010

        @issues
      end

      private

      # -- Shared parsing -------------------------------------------------

      # Entries whose content must be well-formed XML.
      #
      # @return [Array<String>] Entry paths ending in .xml or .rels
      def parsable_parts
        @content.keys.select do |name|
          name.end_with?(".xml", ".rels")
        end
      end

      # Strict-parse every XML entry once, recording OPC-008 on failure.
      #
      # @return [void]
      def parse_all_parts
        parsable_parts.each { |name| parsed_part(name) }
      end

      # Memoized strict parse of one entry.
      #
      # @param name [String] Entry path
      # @return [Nokogiri::XML::Document, nil] Parsed document, or nil when
      #   the entry is malformed (OPC-008 already recorded)
      def parsed_part(name)
        return @parsed_parts[name] if @parsed_parts.key?(name)

        @parsed_parts[name] =
          begin
            Nokogiri::XML(@content[name], &:strict)
          rescue Nokogiri::XML::SyntaxError => e
            add_issue("OPC-008", name,
                      "Malformed XML in #{name}: #{e.message}")
            nil
          end
      end

      # -- OPC-005: content-type coverage ----------------------------------

      def check_content_type_coverage
        ct_name = "[Content_Types].xml"
        unless @content.key?(ct_name)
          add_issue("OPC-005", ct_name,
                    "#{ct_name} is missing; no entry has a declared " \
                    "content type")
          return
        end

        ct_doc = parsed_part(ct_name)
        return unless ct_doc # malformed already reported as OPC-008

        defaults = ct_doc.xpath("//xmlns:Default", "xmlns" => CT_NS)
          .filter_map { |node| node["Extension"] }.to_set
        overrides = ct_doc.xpath("//xmlns:Override", "xmlns" => CT_NS)
          .filter_map { |node| node["PartName"] }.to_set

        @content.each_key do |name|
          next if name.end_with?(".rels") # implicit content type per OPC

          ext = File.extname(name)[1..]
          next if ext && defaults.include?(ext)
          next if overrides.include?("/#{name}")

          add_issue("OPC-005", name,
                    "No content type declared for #{name}")
        end
      end

      # -- OPC-006: relationship target existence --------------------------

      def check_relationship_targets
        rels_parts.each do |rels_name|
          doc = parsed_part(rels_name)
          next unless doc

          base_dir = rels_base_dir(rels_name)
          relationship_nodes(doc).each do |node|
            target = node["Target"]
            next if node["TargetMode"] == "External"
            next unless target
            next if target.start_with?("#")

            resolved = resolve_target(base_dir, target)
            next if @content.key?(resolved)

            add_issue("OPC-006", rels_name,
                      "Relationship target not found: #{resolved} " \
                      "(referenced from #{rels_name})")
          end
        end
      end

      # -- OPC-009: r:id / r:embed / r:link resolution ---------------------

      def check_relationship_references
        @content.keys.each do |name|
          next unless name.end_with?(".xml")

          doc = parsed_part(name)
          next unless doc

          refs = relationship_references(doc)
          next if refs.empty?

          rels_name = rels_path_for(name)
          valid_ids = relationship_ids(rels_name)

          refs.each do |attr_name, rid|
            next if valid_ids.include?(rid)

            add_issue("OPC-009", name,
                      "Relationship reference r:#{attr_name}=\"#{rid}\" in " \
                      "#{name} has no matching Relationship in #{rels_name}")
          end
        end
      end

      # Collect (attribute local name, value) pairs for r:id/r:embed/r:link.
      #
      # @param doc [Nokogiri::XML::Document] Parsed XML part
      # @return [Array<Array(String, String)>] Reference pairs
      def relationship_references(doc)
        refs = []
        doc.traverse do |node|
          next unless node.element?

          node.attribute_nodes.each do |attr|
            next unless attr.namespace&.href == OFFICE_RELS_NS
            next unless R_REF_ATTRIBUTES.include?(attr.node_name)

            value = attr.value
            refs << [attr.node_name, value] unless value.empty?
          end
        end
        refs
      end

      # Relationship IDs declared in one .rels entry.
      #
      # @param rels_name [String] .rels entry path
      # @return [Set<String>] Declared relationship IDs (empty when the
      #   .rels entry is absent or malformed)
      def relationship_ids(rels_name)
        return Set.new unless @content.key?(rels_name)

        doc = parsed_part(rels_name)
        return Set.new unless doc

        relationship_nodes(doc).filter_map { |node| node["Id"] }.to_set
      end

      # -- OPC-010: rId uniqueness ------------------------------------------

      def check_rid_uniqueness
        rels_parts.each do |rels_name|
          doc = parsed_part(rels_name)
          next unless doc

          seen = {}
          relationship_nodes(doc).each do |node|
            id = node["Id"]
            next unless id

            if seen[id]
              add_issue("OPC-010", rels_name,
                        "Duplicate relationship ID #{id} in #{rels_name}")
            else
              seen[id] = true
            end
          end
        end
      end

      # -- Helpers ----------------------------------------------------------

      # @return [Array<String>] .rels entry paths in the content hash
      def rels_parts
        @content.keys.select { |name| name.end_with?(".rels") }
      end

      # Relationship elements of a parsed .rels document.
      #
      # @param doc [Nokogiri::XML::Document] Parsed .rels part
      # @return [Nokogiri::XML::NodeSet] Relationship elements
      def relationship_nodes(doc)
        doc.xpath("//xmlns:Relationship", "xmlns" => RELS_NS)
      end

      # Base directory a .rels entry resolves targets against.
      # "_rels/.rels" => "" (package root);
      # "word/_rels/document.xml.rels" => "word".
      #
      # @param rels_name [String] .rels entry path
      # @return [String] Base directory ("" for the package root)
      def rels_base_dir(rels_name)
        return "" if rels_name.start_with?("_rels/")

        rels_name.sub(%r{/_rels/.*$}, "")
      end

      # The .rels entry path belonging to a part.
      # "word/document.xml" => "word/_rels/document.xml.rels".
      #
      # @param part_name [String] Part entry path
      # @return [String] Corresponding .rels entry path
      def rels_path_for(part_name)
        dir = File.dirname(part_name)
        File.join(dir, "_rels", "#{File.basename(part_name)}.rels")
      end

      # Resolve a relationship target to a normalized entry path,
      # handling leading-slash package-absolute targets and ".." segments.
      #
      # @param base_dir [String] Owning part's directory ("" for root)
      # @param target [String] Raw Target attribute value
      # @return [String] Normalized entry path
      def resolve_target(base_dir, target)
        return target[1..] if target.start_with?("/")

        normalize_package_path(File.join(base_dir, target))
      end

      # Lexically normalize a package-relative path (resolve "." and ".."
      # segments). Deliberately avoids File.expand_path, which prepends a
      # drive letter on Windows.
      #
      # @param path [String] Package-relative path
      # @return [String] Normalized path
      def normalize_package_path(path)
        segments = []
        path.split("/").each do |segment|
          next if segment.empty? || segment == "."

          segment == ".." ? segments.pop : segments << segment
        end
        segments.join("/")
      end

      def add_issue(code, part, message)
        @issues << Validation::Report::ValidationIssue.new(
          severity: "error",
          code: code,
          message: message,
          part: part,
        )
      end
    end
  end
end
