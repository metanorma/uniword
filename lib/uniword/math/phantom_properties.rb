# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Math
      # Phantom formatting properties
      #
      # Generated from OOXML schema: math.yml
      # Element: <m:phantPr>
      class PhantomProperties < Lutaml::Model::Serializable
          attribute :show, String
          attribute :zero_wid, String
          attribute :zero_asc, String
          attribute :zero_desc, String
          attribute :transp, String
          attribute :ctrl_pr, ControlProperties

          xml do
            element 'phantPr'
            namespace Uniword::Ooxml::Namespaces::MathML
            mixed_content

            map_attribute 'val', to: :show
            map_attribute 'val', to: :zero_wid
            map_attribute 'val', to: :zero_asc
            map_attribute 'val', to: :zero_desc
            map_attribute 'val', to: :transp
            map_element 'ctrlPr', to: :ctrl_pr, render_nil: false
          end
      end
    end
end
