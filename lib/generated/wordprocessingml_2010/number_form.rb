# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml2010
      # Number form for advanced typography
      #
      # Generated from OOXML schema: wordprocessingml_2010.yml
      # Element: <w14:numForm>
      class NumberForm < Lutaml::Model::Serializable
          attribute :val, String

          xml do
            root 'numForm'
            namespace 'http://schemas.microsoft.com/office/word/2010/wordml', 'w14'

            map_attribute 'true', to: :val
          end
      end
    end
  end
end
