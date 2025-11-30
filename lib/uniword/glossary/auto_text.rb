# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Glossary
      # Auto text flag for document parts
      #
      # Generated from OOXML schema: glossary.yml
      # Element: <g:auto_text>
      class AutoText < Lutaml::Model::Serializable
          attribute :val, :boolean

          xml do
            element 'auto_text'
            namespace Uniword::Ooxml::Namespaces::Glossary

            map_attribute 'val', to: :val
          end
      end
    end
end
