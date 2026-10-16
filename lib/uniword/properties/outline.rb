# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Properties
    # Outline text effect element
    #
    # Represents <w:outline/> or <w:outline w:val="false"/>
    # Used in run properties (w:rPr) for outline text effect
    class Outline < Lutaml::Model::Serializable
      include BooleanElement

      attribute :val, :string, default: nil
      include BooleanValSetter

      xml do
        element "outline"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "val", to: :val, render_nil: false, render_default: false
      end
    end
  end
end
