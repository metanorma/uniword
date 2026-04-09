# frozen_string_literal: true
require 'lutaml/model'
module Uniword
  module Wordprocessingml
    # Grid after wrapper
    # XML: <w:gridAfter w:val="..."/>
    class GridAfter < Lutaml::Model::Serializable
      attribute :value, :integer
      xml do
        element 'gridAfter'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute 'val', to: :value, render_nil: false
      end
    end
  end
end
