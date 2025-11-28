# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Reference to footer part
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:footerReference>
      class FooterReference < Lutaml::Model::Serializable
          attribute :type, :string
          attribute :id, :string

          xml do
            root 'footerReference'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

            map_attribute 'true', to: :type
            map_attribute 'true', to: :id
          end
      end
    end
  end
end
