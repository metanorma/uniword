# frozen_string_literal: true

module Uniword
  # Represents object defaults in a theme (DrawingML)
  #
  # This element is typically empty in most themes.
  class ObjectDefaults < Lutaml::Model::Serializable
    attribute :ln_def, Drawingml::LineDefaults

    # OOXML namespace configuration
    xml do
      element 'objectDefaults'
      namespace Ooxml::Namespaces::DrawingML
      mixed_content

      map_element 'lnDef', to: :ln_def, render_nil: false
    end

    def initialize(attributes = {})
      super
    end
  end
end