# frozen_string_literal: true

module Uniword
  module Docx
    class PartLoader
      # Loads chart parts (word/charts/chartN.xml) into the document's
      # chart_parts collection, keyed by the id of the document
      # relationship targeting each chart. Charts without a matching
      # document relationship are skipped.
      class ChartLoader
        # @param context [LoadContext] shared load state
        # @param definition [Ooxml::PartDefinition] :chart
        # @return [void]
        def load(context, definition)
          package = context.package
          return unless package.document_rels

          paths = context.matching_paths(definition)
          return if paths.empty?

          paths.each do |path|
            load_chart(context, definition, path)
          end
        end

        private

        def load_chart(context, definition, path)
          target = path.delete_prefix("word/")
          rel = find_chart_relationship(context.package, definition, target)
          return unless rel

          context.package.document.chart_parts[rel.id] = ChartPart.new(
            r_id: rel.id,
            target: target,
            content: context.zip_content[path],
          )
        end

        # The document relationship of the definition's type targeting
        # the chart, or nil when none targets it.
        def find_chart_relationship(package, definition, target)
          package.document_rels.relationships.find do |r|
            r.target == target && r.type.to_s.include?(definition.rel_type)
          end
        end
      end
    end
  end
end
