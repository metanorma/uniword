# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Anchored drawing object
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:anchor>
      class Anchor < Lutaml::Model::Serializable
          attribute :distT, :integer
          attribute :distB, :integer
          attribute :distL, :integer
          attribute :distR, :integer
          attribute :simplePos, SimplePos
          attribute :extent, Extent
          attribute :docPr, DocPr

          xml do
            root 'anchor'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'
            mixed_content

            map_attribute 'true', to: :distT
            map_attribute 'true', to: :distB
            map_attribute 'true', to: :distL
            map_attribute 'true', to: :distR
            map_element 'simplePos', to: :simplePos, render_nil: false
            map_element 'extent', to: :extent, render_nil: false
            map_element 'docPr', to: :docPr, render_nil: false
          end
      end
    end
  end
end
