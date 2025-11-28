# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module VmlOffice
      # Layout rules for VML diagrams
      #
      # Generated from OOXML schema: vml_office.yml
      # Element: <o:rules>
      class VmlRules < Lutaml::Model::Serializable
          attribute :ext, String
          attribute :rule, String, collection: true, default: -> { [] }

          xml do
            root 'rules'
            namespace 'urn:schemas-microsoft-com:vml', 'o'

            map_attribute 'true', to: :ext
            map_element '', to: :rule, render_nil: false
          end
      end
    end
  end
end
