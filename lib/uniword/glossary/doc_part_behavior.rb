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
        root 'behavior'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_attribute 'val', to: :val
      end
    end
  end
end
