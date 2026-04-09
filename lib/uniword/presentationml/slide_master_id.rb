# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Presentationml
    # Slide master identifier reference
    #
    # Generated from OOXML schema: presentationml.yml
    # Element: <p:sld_master_id>
    class SlideMasterId < Lutaml::Model::Serializable
      attribute :id, :integer
      attribute :r_id, :string

      xml do
        element 'sld_master_id'
        namespace Uniword::Ooxml::Namespaces::PresentationalML

        map_attribute 'id', to: :id
        map_attribute 'r:id', to: :r_id
      end
    end
  end
end
