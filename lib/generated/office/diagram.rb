# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Office
      # Diagram container
      #
      # Generated from OOXML schema: office.yml
      # Element: <o:diagram>
      class Diagram < Lutaml::Model::Serializable
          attribute :dgmstyle, String
          attribute :autoformat, String
          attribute :reverse, String
          attribute :autolayout, String
          attribute :dgmscalex, String
          attribute :dgmscaley, String
          attribute :dgmfontsize, String
          attribute :constrainbounds, String

          xml do
            root 'diagram'
            namespace 'urn:schemas-microsoft-com:office:office', 'o'

            map_attribute 'true', to: :dgmstyle
            map_attribute 'true', to: :autoformat
            map_attribute 'true', to: :reverse
            map_attribute 'true', to: :autolayout
            map_attribute 'true', to: :dgmscalex
            map_attribute 'true', to: :dgmscaley
            map_attribute 'true', to: :dgmfontsize
            map_attribute 'true', to: :constrainbounds
          end
      end
    end
  end
end
