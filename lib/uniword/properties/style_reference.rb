# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Properties
    # Style reference element
    #
    # Represents <w:pStyle w:val="..."/> or <w:rStyle w:val="..."/>
    # where value is the style ID being referenced
    class StyleReference < Lutaml::Model::Serializable
      attribute :value, :string

      xml do
        element 'pStyle' # Default, can be overridden
        namespace Ooxml::Namespaces::WordProcessingML

        map_attribute 'val', to: :value
      end
    end
  end
end
