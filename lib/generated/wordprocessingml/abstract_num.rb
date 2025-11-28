# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Abstract numbering definition
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:abstractNum>
      class AbstractNum < Lutaml::Model::Serializable
          attribute :abstractNumId, :integer
          attribute :multiLevelType, MultiLevelType
          attribute :levels, Level, collection: true, default: -> { [] }

          xml do
            root 'abstractNum'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'
            mixed_content

            map_attribute 'true', to: :abstractNumId
            map_element 'multiLevelType', to: :multiLevelType, render_nil: false
            map_element 'lvl', to: :levels, render_nil: false
          end
      end
    end
  end
end
