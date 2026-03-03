# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # VML Picture container
    # Used in AlternateContent Fallback for legacy compatibility
    # Contains VML shapes for backward compatibility with older Word versions
    class Pict < Lutaml::Model::Serializable
      # PATTERN 0: Attributes FIRST
      attribute :shapes, Generated::Vml::Shape, collection: true, default: -> { [] }

      xml do
        root 'pict'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_element 'shape', to: :shapes, render_nil: false
      end
    end
  end
end
