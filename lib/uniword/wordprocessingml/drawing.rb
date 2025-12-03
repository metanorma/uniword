# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Drawing container
    # Contains either Inline (inline with text) or Anchor (positioned/floating)
    class Drawing < Lutaml::Model::Serializable
      # PATTERN 0: Attributes FIRST
      attribute :inline, WpDrawing::Inline
      attribute :anchor, WpDrawing::Anchor

      xml do
        root 'drawing'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_element 'inline', to: :inline, render_nil: false
        map_element 'anchor', to: :anchor, render_nil: false
      end
    end
  end
end