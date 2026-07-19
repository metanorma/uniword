# frozen_string_literal: true

module Uniword
  module Docx
    # Registry-driven loader for DOCX package parts.
    #
    # Replaces the former hand-written per-part sequence in
    # Package.from_zip_content: parts load by iterating
    # Ooxml::PartRegistry.loadable (ordered by
    # Ooxml::PartDefinition#load_priority) and dispatching each
    # definition to the loader strategy registered under
    # Ooxml::PartDefinition#loader.
    #
    # Open/closed: a new part kind adds a strategy class plus a
    # register_loader call and a PartRegistry registration — this loop
    # never changes.
    #
    # @example Load parts into a package
    #   package = Package.new
    #   PartLoader.load(zip_content, package, zip_path: "doc.docx")
    class PartLoader
      autoload :LoadContext, "#{__dir__}/part_loader/load_context"
      autoload :XmlModelLoader, "#{__dir__}/part_loader/xml_model_loader"
      autoload :CustomXmlLoader,
               "#{__dir__}/part_loader/custom_xml_loader"
      autoload :HeaderFooterLoader,
               "#{__dir__}/part_loader/header_footer_loader"
      autoload :ChartLoader, "#{__dir__}/part_loader/chart_loader"
      autoload :ImageLoader, "#{__dir__}/part_loader/image_loader"
      autoload :EmbeddingLoader,
               "#{__dir__}/part_loader/embedding_loader"
      autoload :ThemeMediaLoader,
               "#{__dir__}/part_loader/theme_media_loader"

      class << self
        # Load every registered part from extracted ZIP content into
        # the package.
        #
        # @param zip_content [Hash] extracted ZIP entries
        #   (package path => content)
        # @param package [Package] package to populate
        # @param zip_path [String, nil] original ZIP path for binary
        #   re-extraction (image bytes)
        # @return [Package] the populated package
        def load(zip_content, package, zip_path: nil)
          context = LoadContext.new(zip_content: zip_content,
                                    package: package, zip_path: zip_path)
          Ooxml::PartRegistry.loadable.each do |definition|
            loader_for(definition.loader).load(context, definition)
          end
          package
        end

        # Register a loader strategy under a key.
        #
        # @param key [Symbol] PartDefinition#loader value
        # @param strategy [#load] strategy responding to
        #   +load(context, definition)+
        # @return [Object] the registered strategy
        def register_loader(key, strategy)
          loaders[key.to_sym] = strategy
        end

        # @param key [Symbol] PartDefinition#loader value
        # @return [#load] the registered strategy
        # @raise [ArgumentError] when no strategy is registered
        def loader_for(key)
          loaders.fetch(key.to_sym) do
            raise ArgumentError, "unknown part loader: #{key.inspect}"
          end
        end

        private

        def loaders
          @loaders ||= {}
        end
      end

      register_loader(:xml_model, XmlModelLoader.new)
      register_loader(:custom_xml, CustomXmlLoader.new)
      register_loader(:header_footer, HeaderFooterLoader.new)
      register_loader(:chart, ChartLoader.new)
      register_loader(:image, ImageLoader.new)
      register_loader(:embedding, EmbeddingLoader.new)
      register_loader(:theme_media, ThemeMediaLoader.new)
    end
  end
end
