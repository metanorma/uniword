# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Glossary
    # Text box flag for document parts
    #
    # Generated from OOXML schema: glossary.yml
    # Element: <g:text_box>
    class TextBox < Lutaml::Model::Serializable
      attribute :val, :boolean

      xml do
        element 'text_box'
        namespace Uniword::Ooxml::Namespaces::Glossary

        map_attribute 'val', to: :val
      end
    end
  end
end
