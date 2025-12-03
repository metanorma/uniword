# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Fallback element for alternate content
    # Used in markup compatibility to provide legacy content
    class Fallback < Lutaml::Model::Serializable
      # PATTERN 0: Attributes FIRST
      attribute :pict, Pict
      attribute :drawing, Drawing

      xml do
        root 'Fallback'
        namespace Uniword::Ooxml::Namespaces::MarkupCompatibility
        mixed_content

        map_element 'pict', to: :pict, render_nil: false
        map_element 'drawing', to: :drawing, render_nil: false
      end
    end
  end
end