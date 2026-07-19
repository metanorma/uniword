# frozen_string_literal: true

module Uniword
  module Docx
    class PartLoader
      # Loads customXml data items (customXml/itemN.xml) together with
      # their itemProps and relationships sidecars into
      # CustomXmlItem objects on the package.
      class CustomXmlLoader
        # @param context [LoadContext] shared load state
        # @param definition [Ooxml::PartDefinition] :custom_xml_item
        # @return [void]
        def load(context, definition)
          item_paths = context.matching_paths(definition)
          return if item_paths.empty?

          items = item_paths.sort_by { |path| item_index(path) }.map do |path|
            build_item(context, path)
          end
          context.package.custom_xml_items = items
        end

        private

        def build_item(context, item_path)
          index = item_index(item_path)
          CustomXmlItem.new(
            index: index,
            xml_content: context.zip_content[item_path],
            props_xml: context.zip_content[props_path(index)],
            rels_xml: context.zip_content[sidecar_rels_path(item_path)],
          )
        end

        def item_index(path)
          path[/item(\d+)/, 1].to_i
        end

        def props_path(index)
          Ooxml::PartRegistry.find_by_key(:custom_xml_item_props)
            .path_for(index: index)
        end

        # OPC relationships sidecar of the item part
        # ("customXml/item1.xml" → "customXml/_rels/item1.xml.rels").
        def sidecar_rels_path(item_path)
          File.join(File.dirname(item_path), "_rels",
                    "#{File.basename(item_path)}.rels")
        end
      end
    end
  end
end
