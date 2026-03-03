# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Choice element for alternate content
    # Specifies the preferred content with namespace requirements
    class Choice < Lutaml::Model::Serializable
      # PATTERN 0: Attributes FIRST
      attribute :requires, McRequires
      attribute :drawing, Drawing

      xml do
        root 'Choice'
        namespace Uniword::Ooxml::Namespaces::MarkupCompatibility
        mixed_content

        map_attribute 'Requires', to: :requires
        map_element 'drawing', to: :drawing, render_nil: false
      end
    end
  end
end
