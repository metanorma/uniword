# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Properties
    # Contextual spacing property
    #
    # Represents w:contextualSpacing element in paragraph properties.
    # This is a marker element - its presence means "true" (don't add space
    # between paragraphs of the same style), absence means "false".
    #
    # Element: <w:contextualSpacing/> or <w:contextualSpacing w:val="true"/>
    class ContextualSpacing < Lutaml::Model::Serializable
      attribute :value, :boolean, default: -> { true }

      xml do
        element 'contextualSpacing'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute 'val', to: :value, render_nil: false, render_default: false
      end

      # For truthiness check
      def to_bool
        value == true || value == 1 || value == '1' || value == 'true'
      end
    end
  end
end
