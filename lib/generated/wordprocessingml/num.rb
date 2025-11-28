# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Numbering instance
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:num>
      class Num < Lutaml::Model::Serializable
          attribute :numId, :integer
          attribute :abstractNumId, AbstractNumId

          xml do
            root 'num'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'
            mixed_content

            map_attribute 'true', to: :numId
            map_element 'abstractNumId', to: :abstractNumId, render_nil: false
          end
      end
    end
  end
end
