# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Glossary
      # Text box flag for document parts
      #
      # Generated from OOXML schema: glossary.yml
      # Element: <g:text_box>
      class TextBox < Lutaml::Model::Serializable
          attribute :val, :boolean

          xml do
            root 'text_box'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/glossary', 'g'

            map_attribute 'val', to: :val
          end
      end
    end
  end
end
