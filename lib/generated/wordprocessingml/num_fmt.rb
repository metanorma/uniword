# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Numbering format
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:numFmt>
      class NumFmt < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            root 'numFmt'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

            map_attribute 'true', to: :val
          end
      end
    end
  end
end
