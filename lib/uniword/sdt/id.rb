# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Sdt
    # Unique integer identifier for Structured Document Tag
    # Reference XML: <w:id w:val="-578829839"/>
    class Id < Lutaml::Model::Serializable
      attribute :value, :integer

      xml do
        element 'id'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute 'val', to: :value
      end
    end
  end
end
