# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml2013
      # Footnote column layout
      #
      # Generated from OOXML schema: wordprocessingml_2013.yml
      # Element: <w15:footnoteColumns>
      class FootnoteColumns < Lutaml::Model::Serializable
          attribute :val, Integer

          xml do
            root 'footnoteColumns'
            namespace 'http://schemas.microsoft.com/office/word/2012/wordml', 'w15'

            map_attribute 'true', to: :val
          end
      end
    end
  end
end
