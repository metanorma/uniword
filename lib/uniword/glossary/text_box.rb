# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Glossary
    # Text box flag for document parts
    #
    # Generated from OOXML schema: glossary.yml
    # Element: <g:text_box>
    class TextBox < Lutaml::Model::Serializable
      include Uniword::Properties::BooleanElement
      attribute :val, :string, default: nil
      include Uniword::Properties::BooleanValSetter

      xml do
        element 'text_box'
        namespace Uniword::Ooxml::Namespaces::Glossary
        map_attribute 'val', to: :val, render_nil: false, render_default: false
      end
    end
  end
end
