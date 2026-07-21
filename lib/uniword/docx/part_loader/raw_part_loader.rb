# frozen_string_literal: true

module Uniword
  module Docx
    class PartLoader
      # Fallback loader: preserves ZIP entries no registry definition
      # claims as raw parts (RawPart) on the package, so unmodelled
      # parts (docProps/meta.xml, glossary documents, VBA projects,
      # unmodelled .rels sidecars, ...) round-trip byte-for-byte with
      # their content types and relationships intact.
      #
      # Runs last (load_priority 130 on the :raw_parts definition), so
      # the registry claims every path it models first and this loader
      # carries only the remainder — no double emission. A path is
      # claimed when any PartDefinition matches it (loadable or not),
      # when it is the resolved main document part (or its rels
      # sidecar) at a non-standard location, or when it is a customXml
      # item rels sidecar consumed by CustomXmlLoader.
      #
      # Non-compliant parts (no content type declaration, OS artifact,
      # ...) are stripped at load when
      # `Uniword.configuration.on_noncompliant_content` is `:strip`
      # (the default, matching Word's behavior). In `:raise` mode the
      # parts are preserved and the save-time integrity gate raises
      # with structured OPC-005 issues.
      #
      # Bytes are re-read from the original ZIP when available (the
      # extracted hash may carry corrupted UTF-8 binary); content
      # types come from the loaded [Content_Types].xml model.
      class RawPartLoader
        # customXml item rels sidecars are consumed by CustomXmlLoader
        # together with their item part (captured group: item index).
        CUSTOM_XML_ITEM_RELS =
          %r{\AcustomXml/_rels/item(\d+)\.xml\.rels\z}

        # @param context [LoadContext] shared load state
        # @param _definition [Ooxml::PartDefinition] :raw_parts
        #   (strategy interface; the loader claims by remainder, not
        #   by definition matching)
        # @return [void]
        def load(context, _definition)
          preservable, stripped = partition_unclaimed(context)

          record_stripped(context, stripped)
          return if preservable.empty?

          bytes = raw_bytes(context, preservable)
          rels_by_target = relationships_by_target(context.package)

          preservable.each do |path|
            next unless bytes[path]

            context.package.raw_parts[path] = build_part(
              context.package, path, bytes[path], rels_by_target
            )
          end
        end

        private

        # Split unclaimed paths into preservable and stripped based on
        # the configured policy. In `:raise` mode everything is
        # preserved (existing behavior); the save-time gate handles
        # non-compliance.
        #
        # @return [Array(Array<String>, Array<String>)] preservable
        #   paths and stripped paths (each in zip_content order)
        def partition_unclaimed(context)
          unclaimed = unclaimed_paths(context)
          return [unclaimed, []] if raise_mode?

          classifier = build_classifier(context.package)
          unclaimed.partition { |path| classifier.reason(path).nil? }
        end

        # @return [Boolean] true when the configured policy is :raise
        def raise_mode?
          Uniword.configuration.on_noncompliant_content == :raise
        end

        # Record stripped parts on the package and log each one when
        # save-fix logging is enabled.
        #
        # @return [void]
        def record_stripped(context, stripped)
          return if stripped.empty?

          classifier = build_classifier(context.package)
          stripped.each do |path|
            reason = classifier.reason(path)
            context.package.add_stripped_part(path: path, reason: reason)
            log_strip(path, reason)
          end
        end

        # @return [JunkClassifier] classifier wired to the package's
        #   content types and relationship targets
        def build_classifier(package)
          JunkClassifier.new(
            content_types: package.content_types,
            relationships_by_path: relationships_by_target(package),
          )
        end

        # @return [Hash{String => Array<Ooxml::Relationships::Relationship>}]
        #   target path => relationships referencing it. Multiple rels
        #   may target the same path; the first is used for metadata.
        #   The classifier uses `key?` only.
        def relationships_by_target(package)
          rels_collections(package).each_with_object({}) do |(rels, base), memo|
            rels&.relationships&.each do |rel|
              target = rel.target.to_s
              next if target.empty?

              (memo[resolve_target(base, target)] ||= []) << rel
            end
          end
        end

        # @return [Array<String>] ZIP entries claimed by no registry
        #   loader, in zip_content order
        def unclaimed_paths(context)
          context.zip_content.keys.reject { |path| claimed?(context, path) }
        end

        def claimed?(context, path)
          return true if Ooxml::PartRegistry.find_by_path(path)
          return true if path == context.main_document_path
          return true if path == context.main_document_rels_path

          custom_xml_item_rels?(context, path)
        end

        # A customXml item rels sidecar is claimed (via CustomXmlItem)
        # when its item part is present in the ZIP.
        def custom_xml_item_rels?(context, path)
          match = CUSTOM_XML_ITEM_RELS.match(path)
          return false unless match

          context.zip_content.key?("customXml/item#{match[1]}.xml")
        end

        # @return [RawPart]
        def build_part(package, path, content, rels_by_target)
          rel = first_referencing_relationship(rels_by_target, path)
          RawPart.new(
            path: path,
            content: content,
            content_type: content_type_for(package, path),
            r_id: rel&.id,
            rel_type: rel&.type,
          )
        end

        # Bytes for each path: re-read from the original ZIP when
        # available (binary-safe), else the extracted content.
        #
        # @return [Hash] package path => bytes
        def raw_bytes(context, paths)
          unless context.zip_path
            return paths.to_h { |p| [p, context.zip_content[p]] }
          end

          read_from_zip(context.zip_path, paths)
        end

        def read_from_zip(zip_path, paths)
          require "zip"
          Zip::File.open(zip_path) do |zip_file|
            paths.to_h do |path|
              entry = zip_file.find_entry(path)
              [path, entry&.get_input_stream&.read]
            end
          end
        end

        # Content type the source [Content_Types].xml declared for the
        # part. Delegates to `ContentTypes::Types#content_type_for`
        # (single source of truth for the lookup).
        #
        # @return [String, nil] nil when the source declared neither
        def content_type_for(package, path)
          content_types = package.content_types
          return nil unless content_types

          content_types.content_type_for(path)
        end

        # The first relationship referencing the given path, or nil.
        # Recorded as metadata only; the rel itself stays in its rels
        # collection.
        def first_referencing_relationship(rels_by_target, path)
          rels = rels_by_target[path]
          rels.is_a?(Array) ? rels.first : nil
        end

        # [rels collection, base directory] pairs mirroring the rels
        # parts the package models.
        def rels_collections(package)
          [
            [package.package_rels, ""],
            [package.document_rels, "word"],
            [package.settings_rels, "word"],
            [package.theme_rels, "word/theme"],
            [package.footnotes_rels, "word"],
            [package.endnotes_rels, "word"],
          ]
        end

        # Resolve a relationship target to a normalized package path,
        # handling package-absolute (leading slash) targets and "..".
        def resolve_target(base_dir, target)
          return target[1..] if target.start_with?("/")

          normalize_package_path(File.join(base_dir, target))
        end

        # Lexically normalize a package-relative path (resolve "." and
        # ".." segments).
        def normalize_package_path(path)
          segments = []
          path.split("/").each do |segment|
            next if segment.empty? || segment == "."

            segment == ".." ? segments.pop : segments << segment
          end
          segments.join("/")
        end

        # @return [void]
        def log_strip(path, reason)
          return unless Uniword.configuration.log_save_fixes

          Uniword.logger&.info do
            "Stripped non-compliant part #{path} (#{reason})"
          end
        end
      end
    end
  end
end
