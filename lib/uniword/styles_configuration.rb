# frozen_string_literal: true

# TEMPORARY: v2.0 simplified version - v1.x style classes archived
# require_relative 'style'
# require_relative 'paragraph_style'
# require_relative 'character_style'

module Uniword
  # Manages document-level style configuration
  # Responsibility: Registry and factory for document styles
  #
  # This class maintains the collection of all styles in a document,
  # provides access to styles by ID or name, and generates default styles.
  class StylesConfiguration < Lutaml::Model::Serializable
    # OOXML namespace configuration
    # TEMPORARY: Simplified for v2.0 - style mapping disabled
    xml do
      element 'styles'
      namespace Ooxml::Namespaces::WordProcessingML

      # TEMPORARY: Disabled - requires Style class
      # map_element 'style', to: :styles
    end

    # Collection of all styles (simplified for v2.0)
    # TEMPORARY: Disabled attribute declaration (referenced archived Style class)
    # attribute :styles, Style, collection: true, default: -> { [] }

    # Use simple accessor instead
    def styles
      @styles ||= []
    end

    attr_writer :styles

    # Initialize with optional default styles
    #
    # @param attributes [Hash] Configuration attributes
    def initialize(attributes = {})
      # TEMPORARY: Disable default styles (requires v1.x classes)
      # include_defaults = attributes.delete(:include_defaults) != false
      super
      # add_default_styles if include_defaults && styles.empty?
    end

    # Add a style to the configuration
    #
    # @param style [Style] The style to add
    # @return [Style] The added style
    # @raise [ArgumentError] if style with same ID already exists
    def add_style(style, allow_overwrite: false)
      raise ArgumentError, 'Style must be a Style instance' unless style.is_a?(Style)

      # Skip if ID is empty
      raise ArgumentError, 'Style must have a non-empty ID' if style.id.to_s.strip.empty?

      existing = style_by_id(style.id)
      if existing
        raise ArgumentError, "Style with ID '#{style.id}' already exists" unless allow_overwrite

        # Remove existing and add new
        remove_style(style.id)

      end
      styles << style

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
      add_style(CharacterStyle.default_char) unless style_by_id('DefaultParagraphFont')

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
    # TEMPORARY: Type checking disabled for v2.0
    def add_paragraph_style(style, allow_overwrite: true)
      add_style(style, allow_overwrite: allow_overwrite)
    end

    # Add a character style (alias for add_style with type check)
    # TEMPORARY: Type checking disabled for v2.0
    def add_character_style(style, allow_overwrite: true)
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
