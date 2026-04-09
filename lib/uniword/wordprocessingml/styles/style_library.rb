# frozen_string_literal: true


module Uniword
  module Styles
    # Style Library - loads external style definitions
    #
    # Responsibility: Load and manage style definitions from external YAML files
    # Single Responsibility: Style configuration management only
    #
    # External config: config/styles/*.yml
    #
    # Follows "External Configuration" principle - all styles defined in
    # YAML files, not hardcoded. Supports style inheritance and multiple
    # style types (paragraph, character, list, table, semantic).
    #
    # @example Load ISO standard styles
    #   library = StyleLibrary.load('iso_standard')
    #   title_style = library.paragraph_style(:title)
    #
    # @example Load with custom path
    #   library = StyleLibrary.load_from_file('/custom/styles.yml')
    class StyleLibrary
      attr_reader :name, :version, :description

      # Default styles directory
      STYLES_DIR = File.expand_path('../../../../config/styles', __dir__)

      # Load style library from config/styles directory
      #
      # @param library_name [String, Symbol] Name of the style library
      # @return [StyleLibrary] Loaded style library
      # @raise [Configuration::ConfigurationError] if file not found
      #
      # @example Load ISO standard styles
      #   library = StyleLibrary.load('iso_standard')
      def self.load(library_name)
        file_path = File.join(STYLES_DIR, "#{library_name}.yml")
        load_from_file(file_path)
      end

      # Load style library from specific file path
      #
      # @param file_path [String] Full path to style library YAML file
      # @return [StyleLibrary] Loaded style library
      # @raise [Configuration::ConfigurationError] if file not found
      #
      # @example Load from custom path
      #   library = StyleLibrary.load_from_file('/custom/styles.yml')
      def self.load_from_file(file_path)
        config = Configuration::ConfigurationLoader.load_file(file_path)
        new(config[:style_library])
      end

      # Initialize style library from configuration
      #
      # @param config [Hash] Style library configuration
      def initialize(config)
        @name = config[:name]
        @version = config[:version]
        @description = config[:description]

        @paragraph_styles = load_paragraph_styles(config[:paragraph_styles] || {})
        @character_styles = load_character_styles(config[:character_styles] || {})
        @list_styles = load_list_styles(config[:list_styles] || {})
        @table_styles = load_table_styles(config[:table_styles] || {})
        @semantic_styles = load_semantic_styles(config[:semantic_styles] || {})
      end

      # Get paragraph style definition
      #
      # @param style_name [String, Symbol] Style name
      # @return [ParagraphStyleDefinition] Style definition
      # @raise [ArgumentError] if style not found
      def paragraph_style(style_name)
        @paragraph_styles[style_name.to_sym] ||
          raise(ArgumentError, "Paragraph style not found: #{style_name}")
      end

      # Get character style definition
      #
      # @param style_name [String, Symbol] Style name
      # @return [CharacterStyleDefinition] Style definition
      # @raise [ArgumentError] if style not found
      def character_style(style_name)
        @character_styles[style_name.to_sym] ||
          raise(ArgumentError, "Character style not found: #{style_name}")
      end

      # Get list style definition
      #
      # @param style_name [String, Symbol] Style name
      # @return [ListStyleDefinition] Style definition
      # @raise [ArgumentError] if style not found
      def list_style(style_name)
        @list_styles[style_name.to_sym] ||
          raise(ArgumentError, "List style not found: #{style_name}")
      end

      # Get table style definition
      #
      # @param style_name [String, Symbol] Style name
      # @return [TableStyleDefinition] Style definition
      # @raise [ArgumentError] if style not found
      def table_style(style_name)
        @table_styles[style_name.to_sym] ||
          raise(ArgumentError, "Table style not found: #{style_name}")
      end

      # Get semantic style definition
      #
      # @param style_name [String, Symbol] Style name
      # @return [SemanticStyle] Style definition
      # @raise [ArgumentError] if style not found
      def semantic_style(style_name)
        @semantic_styles[style_name.to_sym] ||
          raise(ArgumentError, "Semantic style not found: #{style_name}")
      end

      # Get all paragraph style names
      #
      # @return [Array<Symbol>] List of paragraph style names
      def paragraph_style_names
        @paragraph_styles.keys
      end

      # Get all character style names
      #
      # @return [Array<Symbol>] List of character style names
      def character_style_names
        @character_styles.keys
      end

      # Get all list style names
      #
      # @return [Array<Symbol>] List of list style names
      def list_style_names
        @list_styles.keys
      end

      # Get all table style names
      #
      # @return [Array<Symbol>] List of table style names
      def table_style_names
        @table_styles.keys
      end

      # Get all semantic style names
      #
      # @return [Array<Symbol>] List of semantic style names
      def semantic_style_names
        @semantic_styles.keys
      end

      private

      # Load paragraph styles from configuration
      #
      # @param config [Hash] Paragraph styles configuration
      # @return [Hash<Symbol, ParagraphStyleDefinition>] Loaded styles
      def load_paragraph_styles(config)
        config.transform_keys(&:to_sym).transform_values do |style_config|
          ParagraphStyleDefinition.new(style_config)
        end
      end

      # Load character styles from configuration
      #
      # @param config [Hash] Character styles configuration
      # @return [Hash<Symbol, CharacterStyleDefinition>] Loaded styles
      def load_character_styles(config)
        config.transform_keys(&:to_sym).transform_values do |style_config|
          CharacterStyleDefinition.new(style_config)
        end
      end

      # Load list styles from configuration
      #
      # @param config [Hash] List styles configuration
      # @return [Hash<Symbol, ListStyleDefinition>] Loaded styles
      def load_list_styles(config)
        config.transform_keys(&:to_sym).transform_values do |style_config|
          ListStyleDefinition.new(style_config)
        end
      end

      # Load table styles from configuration
      #
      # @param config [Hash] Table styles configuration
      # @return [Hash<Symbol, TableStyleDefinition>] Loaded styles
      def load_table_styles(config)
        config.transform_keys(&:to_sym).transform_values do |style_config|
          TableStyleDefinition.new(style_config)
        end
      end

      # Load semantic styles from configuration
      #
      # @param config [Hash] Semantic styles configuration
      # @return [Hash<Symbol, SemanticStyle>] Loaded styles
      def load_semantic_styles(config)
        config.transform_keys(&:to_sym).transform_values do |style_config|
          SemanticStyle.new(style_config)
        end
      end
    end
  end
end
