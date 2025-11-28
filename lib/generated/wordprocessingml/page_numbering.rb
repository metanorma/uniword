# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Page numbering format
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:pgNumType>
      class PageNumbering < Lutaml::Model::Serializable
          attribute :format, :string
          attribute :start, :integer

          xml do
            root 'pgNumType'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

            map_attribute 'true', to: :format
            map_attribute 'true', to: :start
          end
      end
    end
  end
end
