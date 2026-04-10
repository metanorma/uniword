# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Simple integer value wrapper for val="..." /> with a w:val` attribute
    class ValInt < Lutaml::Model::Serializable
      attribute :value, :integer

      xml do
        element 'valInt'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute 'val', to: :value, render_nil: false
      end
    end
  end
end
