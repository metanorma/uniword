# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Presentationml
      # OLE (Object Linking and Embedding) object
      #
      # Generated from OOXML schema: presentationml.yml
      # Element: <p:ole_obj>
      class OleObject < Lutaml::Model::Serializable
          attribute :prog_id, :string
          attribute :r_id, :string
          attribute :show_as_icon, :string

          xml do
            element 'ole_obj'
            namespace Uniword::Ooxml::Namespaces::PresentationalML

            map_attribute 'progId', to: :prog_id
            map_attribute 'id', to: :r_id
            map_attribute 'showAsIcon', to: :show_as_icon
          end
      end
    end
end
