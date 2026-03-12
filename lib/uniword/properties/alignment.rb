# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Properties
    # Namespaced custom type for alignment value
    class AlignmentValue < Lutaml::Model::Type::String
      xml_namespace Ooxml::Namespaces::WordProcessingML
    end

    # Paragraph alignment element
    #
    # Represents <w:jc w:val="..."/> where value is:
    # - left, center, right, both (justified), distribute
    class Alignment < Lutaml::Model::Serializable
      attribute :value, AlignmentValue

      xml do
        element 'jc'
        namespace Ooxml::Namespaces::WordProcessingML

        map_attribute 'val', to: :value
      end
    end
  end
end
