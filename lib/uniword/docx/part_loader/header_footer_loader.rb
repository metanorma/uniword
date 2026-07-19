# frozen_string_literal: true

module Uniword
  module Docx
    class PartLoader
      # Loads header and footer parts (word/headerN.xml,
      # word/footerN.xml) into HeaderFooterPart objects on the
      # document's unified header/footer store. Registered under the
      # :header_footer loader key for both the :header and :footer
      # definitions; the definition selects kind, path pattern,
      # relationship type, and content model.
      #
      # Each part keeps its loaded relationship id, target, and
      # rel_type verbatim, plus the sectPr reference type
      # ("default"/"first"/"even") collected from every section
      # properties element, so the save path can leave loaded
      # relationships untouched.
      class HeaderFooterLoader
        # @param context [LoadContext] shared load state
        # @param definition [Ooxml::PartDefinition] :header or :footer
        # @return [void]
        def load(context, definition)
          package = context.package
          return unless package.document && package.document_rels

          paths = context.matching_paths(definition)
          return if paths.empty?

          load_parts(context, definition, package, paths.sort)
        end

        private

        # Parse each path and append its part to the document's
        # header/footer store.
        def load_parts(context, definition, package, paths)
          ref_types = reference_types(package.document)
          store = package.document.header_footer_parts
          paths.each do |path|
            part = build_part(context, definition, path, ref_types)
            store << part if part
          end
        end

        # Build the part for one path, or nil when no document
        # relationship of the definition's type targets it.
        def build_part(context, definition, path, ref_types)
          target = path.delete_prefix("word/")
          rel = find_relationship(context.package, definition, target)
          return nil unless rel

          HeaderFooterPart.new(
            kind: definition.key,
            r_id: rel.id,
            target: target,
            rel_type: rel.type,
            type: ref_types[rel.id],
            content: definition.loader_model.from_xml(
              context.zip_content[path],
            ),
            loaded: true,
          )
        end

        def find_relationship(package, definition, target)
          package.document_rels.relationships.find do |r|
            r.target == target && r.type.to_s.include?(definition.rel_type)
          end
        end

        # Map relationship id => sectPr reference type
        # ("default"/"first"/"even") from every section properties
        # element (body-level and paragraph-level).
        def reference_types(document)
          types = {}
          section_properties_of(document).each do |sect_pr|
            collect_reference_types(types, sect_pr.header_references)
            collect_reference_types(types, sect_pr.footer_references)
          end
          types
        end

        def collect_reference_types(types, references)
          (references || []).each do |ref|
            types[ref.r_id] = ref.type if ref.r_id
          end
        end

        def section_properties_of(document)
          body = document.body
          return [] unless body

          from_paragraphs = (body.paragraphs || []).filter_map do |para|
            para.properties&.section_properties
          end
          [body.section_properties, *from_paragraphs].compact
        end
      end
    end
  end
end
