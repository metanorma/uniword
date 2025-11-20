# frozen_string_literal: true

require_relative 'style'
require_relative 'paragraph_style'
require_relative 'character_style'

module Uniword
  # Manages document-level style configuration
  # Responsibility: Registry and factory for document styles
  #
  # This class maintains the collection of all styles in a document,
  # provides access to styles by ID or name, and generates default styles.
  class StylesConfiguration < Lutaml::Model::Serializable
    # OOXML namespace configuration
    xml do
      root 'styles'
      namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

      map_element 'style', to: :styles
    end

    # Collection of all styles
    attribute :styles, Style, collection: true, default: -> { [] }

    # Initialize with optional default styles
    #
    # @param attributes [Hash] Configuration attributes
    # @param include_defaults [Boolean] Whether to include default styles
    def initialize(attributes = {}, include_defaults: true)
      super(attributes)
      add_default_styles if include_defaults && styles.empty?
    end

    # Add a style to the configuration
    #
    # @param style [Style] The style to add
    # @return [Style] The added style
    # @raise [ArgumentError] if style with same ID already exists
    def add_style(style, allow_overwrite: false)
      raise ArgumentError, 'Style must be a Style instance' unless style.is_a?(Style)

      # Skip if ID is empty
      if style.id.to_s.strip.empty?
        raise ArgumentError, 'Style must have a non-empty ID'
      end

      existing = style_by_id(style.id)
      if existing
        if allow_overwrite
          # Remove existing and add new
          remove_style(style.id)
          styles << style
        else
          raise ArgumentError, "Style with ID '#{style.id}' already exists"
        end
      else
        styles << style
      end

      style
    end

    # Remove a style by ID
    #
    # @param id [String] The style ID
    # @return [Style, nil] The removed style, or nil if not found
    def remove_style(id)
      style = style_by_id(id)
      return nil unless style

      styles.delete(style)
      style
    end

    # Find a style by ID
    #
    # @param id [String] The style ID
    # @return [Style, nil] The style, or nil if not found
    def style_by_id(id)
      styles.find { |s| s.id == id }
    end

    # Find a style by name
    #
    # @param name [String] The style name
    # @return [Style, nil] The style, or nil if not found
    def style_by_name(name)
      styles.find { |s| s.name == name }
    end

    # Find a style by ID or name
    #
    # @param id_or_name [String] The style ID or name
    # @return [Style, nil] The style, or nil if not found
    def style(id_or_name)
      style_by_id(id_or_name) || style_by_name(id_or_name)
    end

    # Get all paragraph styles
    #
    # @return [Array<ParagraphStyle>] Paragraph styles
    def paragraph_styles
      styles.select(&:paragraph_style?)
    end

    # Get all character styles
    #
    # @return [Array<CharacterStyle>] Character styles
    def character_styles
      styles.select(&:character_style?)
    end

    # Get all default styles
    #
    # @return [Array<Style>] Default styles
    def default_styles
      styles.select(&:default)
    end

    # Get all custom styles
    #
    # @return [Array<Style>] Custom styles
    def custom_styles
      styles.select(&:custom)
    end

    # Get the number of styles
    #
    # @return [Integer] Number of styles
    def count
      styles.size
    end

    alias size count
    alias all_styles styles

    # Check if configuration has any styles
    #
    # @return [Boolean] true if empty
    def empty?
      styles.empty?
    end

    # Check if a style with the given ID exists
    #
    # @param style_id [String] The style ID to check
    # @return [Boolean] true if style exists
    def style_exists?(style_id)
      !style_by_id(style_id).nil?
    end

    # Find a style by ID (alias for clarity)
    #
    # @param style_id [String] The style ID
    # @return [Style, nil] The style, or nil if not found
    def find_by_id(style_id)
      style_by_id(style_id)
    end

    # Add default styles required by Word
    #
    # @return [void]
    def add_default_styles
      # Add Normal paragraph style (required)
      add_style(ParagraphStyle.normal) unless style_by_id('Normal')

      # Add default character style
      unless style_by_id('DefaultParagraphFont')
        add_style(CharacterStyle.default_char)
      end

      # Add heading styles (1-9)
      (1..9).each do |level|
        id = "Heading#{level}"
        add_style(ParagraphStyle.heading(level)) unless style_by_id(id)
      end

      # Add common character styles
      add_style(CharacterStyle.emphasis) unless style_by_id('Emphasis')
      add_style(CharacterStyle.strong) unless style_by_id('Strong')
    end

    # Create a custom paragraph style
    #
    # @param id [String] Style ID
    # @param name [String] Style name
    # @param attributes [Hash] Style attributes
    # @return [ParagraphStyle] The created style
    def create_paragraph_style(id, name, **attributes)
      style = ParagraphStyle.new(
        id: id,
        name: name,
        custom: true,
        **attributes
      )
      add_style(style)
      style
    end

    # Create a custom character style
    #
    # @param id [String] Style ID
    # @param name [String] Style name
    # @param attributes [Hash] Style attributes
    # @return [CharacterStyle] The created style
    def create_character_style(id, name, **attributes)
      style = CharacterStyle.new(
        id: id,
        name: name,
        custom: true,
        **attributes
      )
      add_style(style)
      style
    end

    # Add a paragraph style (alias for add_style with type check)
    # Compatible with docx-js API
    #
    # @param style [ParagraphStyle] The paragraph style to add
    # @return [ParagraphStyle] The added style
    def add_paragraph_style(style, allow_overwrite: true)
      unless style.is_a?(ParagraphStyle)
        raise ArgumentError, 'Style must be a ParagraphStyle instance'
      end
      add_style(style, allow_overwrite: allow_overwrite)
    end

    # Add a character style (alias for add_style with type check)
    # Compatible with docx-js API
    #
    # @param style [CharacterStyle] The character style to add
    # @return [CharacterStyle] The added style
    def add_character_style(style, allow_overwrite: true)
      unless style.is_a?(CharacterStyle)
        raise ArgumentError, 'Style must be a CharacterStyle instance'
      end
      add_style(style, allow_overwrite: allow_overwrite)
    end

    # Validate all styles
    #
    # @return [Boolean] true if all styles are valid
    def valid?
      styles.all?(&:valid?)
    end

    # Resolve style inheritance chain
    # Returns the effective style properties by following basedOn chain
    #
    # @param style_id [String] The style ID to resolve
    # @return [Hash] Merged properties from inheritance chain
    def resolve_inheritance(style_id)
      style = style_by_id(style_id)
      return {} unless style

      style.effective_properties(self)
    end

    # Import styles from another document
    #
    # @param source_document [Document] The source document
    # @return [void]
    def import_from_document(source_document)
      source_document.styles_configuration.all_styles.each do |style|
        add_style(style.dup) unless style_exists?(style.id)
      end
    end

    # Export all styles (creates deep copies)
    #
    # @return [Array<Style>] Array of duplicated styles
    def export_styles
      all_styles.map(&:dup)
    end

    # Merge styles from another configuration
    #
    # @param other_config [StylesConfiguration] The configuration to merge from
    # @param conflict_resolution [Symbol] How to handle conflicts
    #   - :keep_existing (default) - Keep existing style, ignore imported
    #   - :replace - Replace existing with imported
    #   - :rename - Keep both, rename imported with "_imported" suffix
    # @return [void]
    def merge(other_config, conflict_resolution: :keep_existing)
      other_config.all_styles.each do |style|
        if style_exists?(style.id)
          case conflict_resolution
          when :keep_existing
            next
          when :replace
            remove_style(style.id)
            add_style(style.dup)
          when :rename
            new_style = style.dup
            new_style.id = "#{style.id}_imported"
            add_style(new_style)
          else
            raise ArgumentError,
                  "Invalid conflict_resolution: #{conflict_resolution}"
          end
        else
          add_style(style.dup)
        end
      end
    end
  end
end