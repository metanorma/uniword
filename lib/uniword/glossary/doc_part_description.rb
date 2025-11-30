# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Glossary
      # Description text for a document part
      #
      # Generated from OOXML schema: glossary.yml
      # Element: <g:doc_part_description>
      class DocPartDescription < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            element 'doc_part_description'
            namespace Uniword::Ooxml::Namespaces::Glossary

            map_attribute 'val', to: :val
          end
      end
    end
end
