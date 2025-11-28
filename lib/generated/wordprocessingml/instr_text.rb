# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Field instruction text
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:instrText>
      class InstrText < Lutaml::Model::Serializable
          attribute :text, :string

          xml do
            root 'instrText'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'
            mixed_content

            map_element 'text', to: :text, render_nil: false
          end
      end
    end
  end
end
