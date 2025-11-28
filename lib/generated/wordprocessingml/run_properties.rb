# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Run formatting properties
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:rPr>
      class RunProperties < Lutaml::Model::Serializable
          attribute :bold, :boolean
          attribute :italic, :boolean
          attribute :underline, :string
          attribute :font, :string
          attribute :size, :integer
          attribute :color, :string

          xml do
            root 'rPr'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'
            mixed_content

            map_element 'b', to: :bold, render_nil: false
            map_element 'i', to: :italic, render_nil: false
            map_attribute 'val', to: :underline
            map_attribute 'ascii', to: :font
            map_attribute 'val', to: :size
            map_attribute 'val', to: :color
          end
      end
    end
  end
end
