# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml2010
      # Text outline effect for enhanced typography
      #
      # Generated from OOXML schema: wordprocessingml_2010.yml
      # Element: <w14:textOutline>
      class TextOutline < Lutaml::Model::Serializable
          attribute :width, Integer
          attribute :cap, String
          attribute :compound, String
          attribute :align, String

          xml do
            root 'textOutline'
            namespace 'http://schemas.microsoft.com/office/word/2010/wordml', 'w14'

            map_attribute 'true', to: :width
            map_attribute 'true', to: :cap
            map_attribute 'true', to: :compound
            map_attribute 'true', to: :align
          end
      end
    end
  end
end
