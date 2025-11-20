# frozen_string_literal: true

module Uniword
  # Represents a font scheme from a Word document theme.
  #
  # Font schemes define the major (heading) and minor (body) fonts
  # used throughout the document.
  #
  # @example Create a custom font scheme
  #   scheme = Uniword::FontScheme.new
  #   scheme.major_font = 'Helvetica'
  #   scheme.minor_font = 'Arial'
  class FontScheme < Lutaml::Model::Serializable
    # OOXML namespace configuration
    xml do
      root 'fontScheme'
      namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'

      map_attribute 'name', to: :name
    end

    # Font scheme name
    attribute :name, :string, default: -> { 'Office' }

    # Major font (used for headings)
    attr_accessor :major_font

    # Minor font (used for body text)
    attr_accessor :minor_font

    # Additional fonts for different scripts
    attr_accessor :major_east_asian, :major_complex_script
    attr_accessor :minor_east_asian, :minor_complex_script

    # Initialize font scheme
    #
    # @param attributes [Hash] Font scheme attributes
    def initialize(attributes = {})
      super
      @major_font = nil
      @minor_font = nil
      @major_east_asian = nil
      @major_complex_script = nil
      @minor_east_asian = nil
      @minor_complex_script = nil
      initialize_default_fonts if @major_font.nil? && @minor_font.nil?
    end

    # Duplicate the font scheme
    #
    # @return [FontScheme] A deep copy of this font scheme
    def dup
      new_scheme = FontScheme.new(name: name)
      new_scheme.major_font = @major_font
      new_scheme.minor_font = @minor_font
      new_scheme.major_east_asian = @major_east_asian
      new_scheme.major_complex_script = @major_complex_script
      new_scheme.minor_east_asian = @minor_east_asian
      new_scheme.minor_complex_script = @minor_complex_script
      new_scheme
    end

    private

    # Initialize with default Office theme fonts
    def initialize_default_fonts
      @major_font = 'Calibri Light'
      @minor_font = 'Calibri'
    end
  end
end