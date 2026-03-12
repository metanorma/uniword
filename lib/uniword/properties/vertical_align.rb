# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Properties
    # Namespaced custom type for vertical alignment value
    class VerticalAlignValue < Lutaml::Model::Type::String
      xml_namespace Ooxml::Namespaces::WordProcessingML
    end

    # Text vertical alignment element
    #
    # Represents <w:vertAlign w:val="..."/> where value is:
    # - baseline, superscript, subscript
    class VerticalAlign < Lutaml::Model::Serializable
      attribute :value, VerticalAlignValue

      xml do
        element 'vertAlign'
        namespace Ooxml::Namespaces::WordProcessingML

        map_attribute 'val', to: :value
      end
    end
  end
end
