# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Sdt
    # Developer tag for Structured Document Tag (can be empty)
    # Reference XML: <w:tag w:val=""/>
    class Tag < Lutaml::Model::Serializable
      attribute :value, :string

      xml do
        element 'tag'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute 'val', to: :value, render_nil: false
      end
    end
  end
end