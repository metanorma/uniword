# frozen_string_literal: true

module Uniword
  # Represents object defaults in a theme (DrawingML)
  #
  # This element is typically empty in most themes.
  class ObjectDefaults < Lutaml::Model::Serializable
    # OOXML namespace configuration
    xml do
      element 'objectDefaults'
      namespace Ooxml::Namespaces::DrawingML
    end

    def initialize(attributes = {})
      super
    end
  end
end