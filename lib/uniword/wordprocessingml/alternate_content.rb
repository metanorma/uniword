# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # AlternateContent element for markup compatibility
    # Allows documents to specify modern and legacy versions of content
    class AlternateContent < Lutaml::Model::Serializable
      # PATTERN 0: Attributes FIRST
      attribute :choice, Choice
      attribute :fallback, Fallback, default: nil

      xml do
        root 'AlternateContent'
        namespace Uniword::Ooxml::Namespaces::MarkupCompatibility
        mixed_content

        map_element 'Choice', to: :choice
        map_element 'Fallback', to: :fallback, render_nil: false
      end
    end
  end
end
