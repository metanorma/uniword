# frozen_string_literal: true

require "zip"
require "nokogiri"
require_relative "report/validation_issue"

module Uniword
  module Validation
    # OPC Package validation — validates the Open Packaging Convention structure.
    #
    # Designed to be extractable into its own gem. Contains no Word-specific
    # logic. Validates ZIP integrity, content types, relationships, and
    # part presence per ISO/IEC 29500-2 (OPC).
    #
    # Checks:
    # - OPC-001: ZIP opens without error
    # - OPC-002: [Content_Types].xml exists
    # - OPC-003: _rels/.rels exists
    # - OPC-004: word/document.xml exists
    # - OPC-005: Content types cover all file extensions
    # - OPC-006: Relationship targets resolve
    # - OPC-007: No orphaned parts
    # - OPC-008: Well-formed XML in all parts
    #
    # @example Validate a DOCX package
    #   validator = OpcValidator.new
    #   issues = validator.validate("document.docx")
    #   issues.each { |issue| puts "#{issue.code}: #{issue.message}" }
    class OpcValidator
      RELS_NS = "http://schemas.openxmlformats.org/package/2006/relationships"
      CT_NS = "http://schemas.openxmlformats.org/package/2006/content-types"

      # Required parts per OPC specification
      REQUIRED_PARTS = %w[
        [Content_Types].xml
        _rels/.rels
      ].freeze

      # Required parts for DOCX specifically
      DOCX_REQUIRED = %w[
        word/document.xml
      ].freeze

      # Validate an OPC package.
      #
      # @param path [String] Path to .docx file
      # @return [Array<Report::ValidationIssue>] Issues found
      def validate(path)
        issues = []

        zip = open_zip(path, issues)
        return issues unless zip

        begin
          check_required_parts(zip, issues)
          check_content_types(zip, issues)
          check_relationships(zip, issues)
          check_xml_well_formedness(zip, issues)
        ensure
          zip.close
        end

        issues
      end

      private

      def open_zip(path, issues)
        Zip::File.open(path)
      rescue Zip::Error => e
        issues << Report::ValidationIssue.new(
          severity: "error",
          code: "OPC-001",
          message: "Cannot open ZIP file: #{e.message}",
          suggestion: "Ensure the file is a valid .docx (ZIP) archive.",
        )
        nil
      end

      def check_required_parts(zip, issues)
        REQUIRED_PARTS.each do |part|
          next if zip.find_entry(part)

          issues << Report::ValidationIssue.new(
            severity: "error",
            code: "OPC-002",
            message: "Missing required OPC part: #{part}",
            part: part,
            suggestion: "This is a required part per ISO/IEC 29500-2. " \
                        "The file may be corrupted.",
          )
        end

        DOCX_REQUIRED.each do |part|
          next if zip.find_entry(part)

          issues << Report::ValidationIssue.new(
            severity: "error",
            code: "OPC-004",
            message: "Missing required DOCX part: #{part}",
            part: part,
            suggestion: "The main document content is missing.",
          )
        end
      end

      def check_content_types(zip, issues)
        ct_entry = zip.find_entry("[Content_Types].xml")
        return unless ct_entry

        ct_doc = Nokogiri::XML(ct_entry.get_input_stream.read, &:strict)

        # Get declared extensions
        declared_exts = ct_doc.xpath("//xmlns:Default", "xmlns" => CT_NS)
          .filter_map { |n| n["Extension"] }.to_set

        # Get declared overrides
        declared_overrides = ct_doc.xpath("//xmlns:Override", "xmlns" => CT_NS)
          .filter_map { |n| n["PartName"] }.to_set

        # Check all files have content types
        # (skip .rels files — they have implicit content type per OPC spec)
        zip.entries.each do |entry|
          next if entry.directory?
          next if entry.name.end_with?(".rels")

          ext = File.extname(entry.name)[1..]
          has_default = ext && declared_exts.include?(ext)
          has_override = declared_overrides.include?("/#{entry.name}")

          next if has_default || has_override

          issues << Report::ValidationIssue.new(
            severity: "warning",
            code: "OPC-005",
            message: "No content type declared for #{entry.name}",
            part: entry.name,
            suggestion: "Add a Default or Override entry in [Content_Types].xml.",
          )
        end
      rescue Nokogiri::XML::SyntaxError => e
        issues << Report::ValidationIssue.new(
          severity: "error",
          code: "OPC-008",
          message: "Malformed [Content_Types].xml: #{e.message}",
          part: "[Content_Types].xml",
        )
      end

      def check_relationships(zip, issues)
        rel_entries = zip.entries.select { |e| e.name.end_with?(".rels") }

        rel_entries.each do |entry|
          check_relationship_file(zip, entry, issues)
        end
      end

      def check_relationship_file(zip, entry, issues)
        doc = Nokogiri::XML(entry.get_input_stream.read)

        base_dir = compute_base_dir(entry.name)

        doc.xpath("//xmlns:Relationship", "xmlns" => RELS_NS).each do |rel|
          target = rel["Target"]
          mode = rel["TargetMode"]

          # Skip external relationships
          next if mode == "External"
          next unless target
          next if target.start_with?("#")

          target_path = resolve_target(base_dir, target)
          next if zip.find_entry(target_path)

          issues << Report::ValidationIssue.new(
            severity: "error",
            code: "OPC-006",
            message: "Relationship target not found: #{target_path} " \
                     "(referenced from #{entry.name})",
            part: entry.name,
            suggestion: "The part '#{target_path}' is referenced but missing " \
                        "from the package. Remove the relationship or add the part.",
          )
        end
      rescue Nokogiri::XML::SyntaxError => e
        issues << Report::ValidationIssue.new(
          severity: "error",
          code: "OPC-008",
          message: "Malformed relationship file #{entry.name}: #{e.message}",
          part: entry.name,
        )
      end

      def check_xml_well_formedness(zip, issues)
        xml_entries = zip.entries.select { |e| e.name.end_with?(".xml") }

        xml_entries.each do |entry|
          content = entry.get_input_stream.read
          Nokogiri::XML(content, &:strict)
        rescue Nokogiri::XML::SyntaxError => e
          issues << Report::ValidationIssue.new(
            severity: "error",
            code: "OPC-008",
            message: "Malformed XML in #{entry.name}: #{e.message}",
            part: entry.name,
            suggestion: "The XML part is not well-formed and may cause " \
                        "applications to reject the file.",
          )
        end
      end

      def compute_base_dir(rels_path)
        # _rels/.rels => "" (root)
        # word/_rels/document.xml.rels => "word"
        if rels_path.start_with?("_rels/")
          ""
        else
          rels_path.sub(%r{/_rels/.*$}, "")
        end
      end

      def resolve_target(base_dir, target)
        return target[1..] if target.start_with?("/")

        base_dir.empty? ? target : File.join(base_dir, target)
      end
    end
  end
end
