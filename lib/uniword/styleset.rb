# frozen_string_literal: true

require_relative 'style'

module Uniword
  # Represents a StyleSet containing a collection of style definitions
  #
  # StyleSets are named collections of paragraph, character, table, and
  # numbering styles that provide consistent formatting for Word documents.
  # They work in conjunction with themes to create professionally styled documents.
  #
  # @example Load StyleSet from .dotx file
  #   styleset = Uniword::StyleSet.from_dotx('Distinctive.dotx')
  #   puts styleset.name
  #   puts "Styles: #{styleset.styles.count}"
  #
  # @example Apply StyleSet to document
  #   doc = Uniword::Document.new
  #   styleset.apply_to(doc)
  class StyleSet < Lutaml::Model::Serializable
    # YAML serialization (for bundled stylesets)
    yaml do
      map 'name', to: :name
      map 'source_file', to: :source_file
      map 'styles', to: :styles
    end

    # StyleSet name
    attribute :name, :string, default: -> { 'Custom StyleSet' }

    # Collection of Style objects
    attribute :styles, Style, collection: true, default: -> { [] }

    # Source .dotx file path (for reference)
    attribute :source_file, :string

    # Initialize StyleSet
    #
    # @param attributes [Hash] StyleSet attributes
    def initialize(attributes = {})
      super
      @styles ||= []
      @source_file = nil
    end

    # Get the number of styles
    #
    # @return [Integer] Number of styles
    def count
      styles.size
    end

    alias size count

    # Check if StyleSet is valid
    #
    # @return [Boolean] true if valid
    def valid?
      !name.nil? && !name.empty? && styles.is_a?(Array)
    end

    # Get styles by type
    #
    # @param type [String, Symbol] Style type (:paragraph, :character, :table, :numbering)
    # @return [Array<Style>] Styles of the specified type
    def styles_by_type(type)
      type_str = type.to_s
      styles.select { |s| s.type == type_str }
    end

    # Get paragraph styles
    #
    # @return [Array<Style>] Paragraph styles
    def paragraph_styles
      styles_by_type('paragraph')
    end

    # Get character styles
    #
    # @return [Array<Style>] Character styles
    def character_styles
      styles_by_type('character')
    end

    # Get table styles
    #
    # @return [Array<Style>] Table styles
    def table_styles
      styles_by_type('table')
    end

    # Provide detailed inspection for debugging
    #
    # @return [String] A readable representation of the StyleSet
    def inspect
      "#<Uniword::StyleSet name=#{name.inspect} " \
        "styles=#{styles.count} " \
        "source=#{source_file.inspect}>"
    end

    # Load StyleSet from .dotx file
    #
    # @param path [String] Path to .dotx file
    # @return [StyleSet] Loaded StyleSet
    #
    # @example Load StyleSet
    #   styleset = StyleSet.from_dotx('Distinctive.dotx')
    def self.from_dotx(path)
      require_relative 'stylesets/styleset_loader'

      loader = StyleSets::StyleSetLoader.new
      loader.load(path)
    end

    # Load bundled StyleSet by name
    #
    # @param name [String] StyleSet name (e.g., 'distinctive', 'basic')
    # @return [StyleSet] Loaded StyleSet
    #
    # @example Load bundled StyleSet
    #   styleset = StyleSet.load('distinctive')
    def self.load(name)
      require_relative 'stylesets/yaml_styleset_loader'

      StyleSets::YamlStyleSetLoader.load_bundled(name)
    end

    # List all available bundled StyleSets
    #
    # @return [Array<String>] StyleSet names
    #
    # @example List StyleSets
    #   stylesets = StyleSet.available_stylesets
    #   # => ["distinctive", "basic", ...]
    def self.available_stylesets
      require_relative 'stylesets/yaml_styleset_loader'

      StyleSets::YamlStyleSetLoader.available_stylesets
    end

    # Apply this StyleSet to a document
    #
    # Merges all styles from this StyleSet into the document's
    # styles configuration.
    #
    # @param document [Document] Target document
    # @param strategy [Symbol] Conflict resolution strategy
    #   - :keep_existing (default) - Keep existing styles
    #   - :replace - Replace existing with StyleSet styles
    #   - :rename - Keep both, rename imported styles
    # @return [void]
    def apply_to(document, strategy: :keep_existing)
      return unless document.respond_to?(:styles_configuration)

      styles.each do |style|
        case strategy
        when :replace
          document.styles_configuration.add_style(style.dup, allow_overwrite: true)
        when :keep_existing
          unless document.styles_configuration.style_exists?(style.id)
            document.styles_configuration.add_style(style.dup)
          end
        when :rename
          if document.styles_configuration.style_exists?(style.id)
            new_style = style.dup
            new_style.id = "#{style.id}_styleset"
            document.styles_configuration.add_style(new_style)
          else
            document.styles_configuration.add_style(style.dup)
          end
        else
          raise ArgumentError, "Invalid strategy: #{strategy}"
        end
      end
    end
  end
end