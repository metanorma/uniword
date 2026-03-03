# frozen_string_literal: true

module Uniword
  # Represents a latin, ea, or cs font element
  class FontTypeface < Lutaml::Model::Serializable
    attribute :typeface, :string, default: -> { '' }
    attribute :panose, :string

    def initialize(attributes = {})
      super
      @panose ||= nil
    end
  end

  # Latin font element
  class LatinFont < FontTypeface
    xml do
      element 'latin'
      namespace Ooxml::Namespaces::DrawingML
      map_attribute 'typeface', to: :typeface
      map_attribute 'panose', to: :panose
    end
  end

  # East Asian font element
  class EaFont < FontTypeface
    xml do
      element 'ea'
      namespace Ooxml::Namespaces::DrawingML
      map_attribute 'typeface', to: :typeface, value_map: {
        to: { empty: :empty, nil: :empty, omitted: :omitted }
      }
    end
  end

  # Complex Script font element
  class CsFont < FontTypeface
    xml do
      element 'cs'
      namespace Ooxml::Namespaces::DrawingML
      map_attribute 'typeface', to: :typeface, value_map: {
        to: { empty: :empty, nil: :empty, omitted: :omitted }
      }
    end
  end

  # Script-specific font element
  class ScriptFont < Lutaml::Model::Serializable
    attribute :script, :string
    attribute :typeface, :string

    xml do
      element 'font'
      namespace Ooxml::Namespaces::DrawingML
      map_attribute 'script', to: :script, render_nil: false
      map_attribute 'typeface', to: :typeface, render_nil: false
    end

    def initialize(attributes = {})
      super
      # Don't set default empty strings - let lutaml-model handle nil
    end
  end

  # Major font container
  class MajorFont < Lutaml::Model::Serializable
    attribute :latin, LatinFont
    attribute :ea, EaFont
    attribute :cs, CsFont
    attribute :fonts, ScriptFont, collection: true

    xml do
      element 'majorFont'
      namespace Ooxml::Namespaces::DrawingML
      map_element 'latin', to: :latin
      map_element 'ea', to: :ea
      map_element 'cs', to: :cs
      map_element 'font', to: :fonts
    end

    def initialize(attributes = {})
      super
      @latin ||= LatinFont.new(typeface: 'Calibri Light')
      @ea ||= EaFont.new
      @cs ||= CsFont.new
      @fonts ||= []
    end
  end

  # Minor font container
  class MinorFont < Lutaml::Model::Serializable
    attribute :latin, LatinFont
    attribute :ea, EaFont
    attribute :cs, CsFont
    attribute :fonts, ScriptFont, collection: true

    xml do
      element 'minorFont'
      namespace Ooxml::Namespaces::DrawingML
      map_element 'latin', to: :latin
      map_element 'ea', to: :ea
      map_element 'cs', to: :cs
      map_element 'font', to: :fonts
    end

    def initialize(attributes = {})
      super
      @latin ||= LatinFont.new(typeface: 'Calibri')
      @ea ||= EaFont.new
      @cs ||= CsFont.new
      @fonts ||= []
    end
  end

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
    # Font scheme name
    attribute :name, :string, default: -> { 'Office' }

    # Major font container
    attribute :major_font_obj, MajorFont

    # Minor font container
    attribute :minor_font_obj, MinorFont

    # OOXML namespace configuration
    xml do
      element 'fontScheme'
      namespace Ooxml::Namespaces::DrawingML

      map_attribute 'name', to: :name
      map_element 'majorFont', to: :major_font_obj
      map_element 'minorFont', to: :minor_font_obj
    end

    # Initialize font scheme
    #
    # @param attributes [Hash] Font scheme attributes
    def initialize(attributes = {})
      super
      @major_font_obj ||= MajorFont.new
      @minor_font_obj ||= MinorFont.new
    end

    # Get major font name (compatibility accessor)
    def major_font
      @major_font_obj&.latin&.typeface
    end

    # Set major font name (compatibility accessor)
    def major_font=(typeface)
      @major_font_obj ||= MajorFont.new
      @major_font_obj.latin ||= LatinFont.new
      @major_font_obj.latin.typeface = typeface
    end

    # Get minor font name (compatibility accessor)
    def minor_font
      @minor_font_obj&.latin&.typeface
    end

    # Set minor font name (compatibility accessor)
    def minor_font=(typeface)
      @minor_font_obj ||= MinorFont.new
      @minor_font_obj.latin ||= LatinFont.new
      @minor_font_obj.latin.typeface = typeface
    end

    # Get major East Asian font
    def major_east_asian
      @major_font_obj&.ea&.typeface
    end

    # Set major East Asian font
    def major_east_asian=(typeface)
      @major_font_obj ||= MajorFont.new
      @major_font_obj.ea ||= EaFont.new
      @major_font_obj.ea.typeface = typeface
    end

    # Get major complex script font
    def major_complex_script
      @major_font_obj&.cs&.typeface
    end

    # Set major complex script font
    def major_complex_script=(typeface)
      @major_font_obj ||= MajorFont.new
      @major_font_obj.cs ||= CsFont.new
      @major_font_obj.cs.typeface = typeface
    end

    # Get minor East Asian font
    def minor_east_asian
      @minor_font_obj&.ea&.typeface
    end

    # Set minor East Asian font
    def minor_east_asian=(typeface)
      @minor_font_obj ||= MinorFont.new
      @minor_font_obj.ea ||= EaFont.new
      @minor_font_obj.ea.typeface = typeface
    end

    # Get minor complex script font
    def minor_complex_script
      @minor_font_obj&.cs&.typeface
    end

    # Set minor complex script font
    def minor_complex_script=(typeface)
      @minor_font_obj ||= MinorFont.new
      @minor_font_obj.cs ||= CsFont.new
      @minor_font_obj.cs.typeface = typeface
    end

    # Duplicate the font scheme
    #
    # @return [FontScheme] A deep copy of this font scheme
    def dup
      new_scheme = FontScheme.new(name: name)
      new_scheme.major_font = major_font
      new_scheme.minor_font = minor_font
      new_scheme.major_east_asian = major_east_asian if major_east_asian
      new_scheme.major_complex_script = major_complex_script if major_complex_script
      new_scheme.minor_east_asian = minor_east_asian if minor_east_asian
      new_scheme.minor_complex_script = minor_complex_script if minor_complex_script
      new_scheme
    end
  end
end
