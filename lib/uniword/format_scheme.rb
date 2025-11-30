# frozen_string_literal: true

require_relative 'drawingml/solid_fill'
require_relative 'drawingml/gradient_fill'
require_relative 'drawingml/line_properties'
require_relative 'drawingml/effect_list'

module Uniword
  # Represents an effect style in DrawingML format scheme
  class EffectStyle < Lutaml::Model::Serializable
    attribute :effect_lst, Drawingml::EffectList

    xml do
      element 'effectStyle'
      namespace Ooxml::Namespaces::DrawingML
      map_element 'effectLst', to: :effect_lst
    end

    def initialize(attributes = {})
      super
      @effect_lst ||= Drawingml::EffectList.new
    end
  end

  # Represents fill style list in DrawingML format scheme
  class FillStyleList < Lutaml::Model::Serializable
    attribute :solid_fills, Drawingml::SolidFill, collection: true
    attribute :gradient_fills, Drawingml::GradientFill, collection: true

    xml do
      element 'fillStyleLst'
      namespace Ooxml::Namespaces::DrawingML
      mixed_content
      map_element 'solidFill', to: :solid_fills
      map_element 'gradFill', to: :gradient_fills
    end

    def initialize(attributes = {})
      super
      @solid_fills ||= []
      @gradient_fills ||= []
    end
  end

  # Represents line style list in DrawingML format scheme
  class LineStyleList < Lutaml::Model::Serializable
    attribute :lines, Drawingml::LineProperties, collection: true

    xml do
      element 'lnStyleLst'
      namespace Ooxml::Namespaces::DrawingML
      map_element 'ln', to: :lines
    end

    def initialize(attributes = {})
      super
      @lines ||= []
    end
  end

  # Represents effect style list in DrawingML format scheme
  class EffectStyleList < Lutaml::Model::Serializable
    attribute :effect_styles, EffectStyle, collection: true

    xml do
      element 'effectStyleLst'
      namespace Ooxml::Namespaces::DrawingML
      map_element 'effectStyle', to: :effect_styles
    end

    def initialize(attributes = {})
      super
      @effect_styles ||= []
    end
  end

  # Represents background fill style list in DrawingML format scheme
  class BackgroundFillStyleList < Lutaml::Model::Serializable
    attribute :solid_fills, Drawingml::SolidFill, collection: true
    attribute :gradient_fills, Drawingml::GradientFill, collection: true

    xml do
      element 'bgFillStyleLst'
      namespace Ooxml::Namespaces::DrawingML
      mixed_content
      map_element 'solidFill', to: :solid_fills
      map_element 'gradFill', to: :gradient_fills
    end

    def initialize(attributes = {})
      super
      @solid_fills ||= []
      @gradient_fills ||= []
    end
  end

  # Represents format scheme in a DrawingML theme
  #
  # Format schemes define fill, line, effect, and background styles.
  class FormatScheme < Lutaml::Model::Serializable
    # Format scheme name
    attribute :name, :string, default: -> { 'Office' }

    # Fill style list
    attribute :fill_style_lst, FillStyleList

    # Line style list
    attribute :ln_style_lst, LineStyleList

    # Effect style list
    attribute :effect_style_lst, EffectStyleList

    # Background fill style list
    attribute :bg_fill_style_lst, BackgroundFillStyleList

    # OOXML namespace configuration
    xml do
      element 'fmtScheme'
      namespace Ooxml::Namespaces::DrawingML

      map_attribute 'name', to: :name
      map_element 'fillStyleLst', to: :fill_style_lst
      map_element 'lnStyleLst', to: :ln_style_lst
      map_element 'effectStyleLst', to: :effect_style_lst
      map_element 'bgFillStyleLst', to: :bg_fill_style_lst
    end

    def initialize(attributes = {})
      super
      @fill_style_lst ||= FillStyleList.new
      @ln_style_lst ||= LineStyleList.new
      @effect_style_lst ||= EffectStyleList.new
      @bg_fill_style_lst ||= BackgroundFillStyleList.new
    end
  end
end