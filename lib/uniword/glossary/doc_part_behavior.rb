# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Glossary
      # Individual behavior specification
      #
      # Generated from OOXML schema: glossary.yml
      # Element: <g:doc_part_behavior>
      class DocPartBehavior < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            element 'doc_part_behavior'
            namespace Uniword::Ooxml::Namespaces::Glossary

            map_attribute 'val', to: :val
          end
      end
    end
end
