# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Style name
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:name>
      class StyleName < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            root 'name'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

            map_attribute 'true', to: :val
          end
      end
    end
  end
end
