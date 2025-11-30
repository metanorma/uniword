# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module VmlOffice
      # Layout rules for VML diagrams
      #
      # Generated from OOXML schema: vml_office.yml
      # Element: <o:rules>
      class VmlRules < Lutaml::Model::Serializable
          attribute :ext, String
          attribute :rule, String, collection: true, default: -> { [] }

          xml do
            element 'rules'
            namespace Uniword::Ooxml::Namespaces::Vml

            map_attribute 'ext', to: :ext
            map_element '', to: :rule, render_nil: false
          end
      end
    end
end
