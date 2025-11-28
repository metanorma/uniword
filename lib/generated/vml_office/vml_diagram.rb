# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module VmlOffice
      # VML diagram container
      #
      # Generated from OOXML schema: vml_office.yml
      # Element: <o:diagram>
      class VmlDiagram < Lutaml::Model::Serializable
          attribute :dgmstyle, String
          attribute :autoformat, String
          attribute :reverse, String
          attribute :autolayout, String
          attribute :dgmscalex, String
          attribute :dgmscaley, String

          xml do
            root 'diagram'
            namespace 'urn:schemas-microsoft-com:vml', 'o'

            map_attribute 'true', to: :dgmstyle
            map_attribute 'true', to: :autoformat
            map_attribute 'true', to: :reverse
            map_attribute 'true', to: :autolayout
            map_attribute 'true', to: :dgmscalex
            map_attribute 'true', to: :dgmscaley
          end
      end
    end
  end
end
