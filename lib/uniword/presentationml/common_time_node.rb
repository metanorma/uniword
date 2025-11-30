# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Presentationml
      # Common properties for all time node types
      #
      # Generated from OOXML schema: presentationml.yml
      # Element: <p:c_tn>
      class CommonTimeNode < Lutaml::Model::Serializable
          attribute :id, :integer
          attribute :dur, :string
          attribute :restart, :string
          attribute :fill, :string
          attribute :st_cond_lst, StartConditionsList
          attribute :end_cond_lst, EndConditionsList

          xml do
            element 'c_tn'
            namespace Uniword::Ooxml::Namespaces::PresentationalML
            mixed_content

            map_attribute 'id', to: :id
            map_attribute 'dur', to: :dur
            map_attribute 'restart', to: :restart
            map_attribute 'fill', to: :fill
            map_element 'stCondLst', to: :st_cond_lst, render_nil: false
            map_element 'endCondLst', to: :end_cond_lst, render_nil: false
          end
      end
    end
end
