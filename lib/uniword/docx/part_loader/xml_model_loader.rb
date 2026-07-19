# frozen_string_literal: true

module Uniword
  module Docx
    class PartLoader
      # Loads fixed-path XML parts: parses the part's XML with the
      # definition's loader_model and assigns the model to the
      # definition's package attribute. Covers every part whose load
      # is "parse one part into one attribute": the content types,
      # all rels parts, docProps, the main document, styles,
      # numbering, settings, font table, web settings, theme,
      # footnotes, endnotes, and comments.
      #
      # Definitions with a path_resolution rule resolve their path
      # dynamically (main document via the package officeDocument
      # relationship; its rels part as the sidecar of the resolved
      # path), falling back to the definition's fixed path.
      class XmlModelLoader
        # @param context [LoadContext] shared load state
        # @param definition [Ooxml::PartDefinition] part to load
        # @return [void]
        def load(context, definition)
          content = read_content(context, definition)
          return unless content

          model = definition.loader_model.from_xml(content)
          context.package.method(:"#{definition.package_attribute}=")
            .call(model)
        end

        private

        # Part content from the first candidate path present in the
        # ZIP, preserving the historic resolved-then-fixed fallback.
        def read_content(context, definition)
          candidate_paths(context, definition).each do |path|
            content = context.zip_content[path]
            return content if content
          end
          nil
        end

        def candidate_paths(context, definition)
          case definition.path_resolution
          when :office_document
            [context.main_document_path, definition.path].compact
          when :office_document_rels
            [context.main_document_rels_path, definition.path].compact
          else
            [definition.path]
          end
        end
      end
    end
  end
end
