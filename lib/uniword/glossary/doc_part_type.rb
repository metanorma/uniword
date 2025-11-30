# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Glossary
    # Type specification for a document part
    #
    # Generated from OOXML schema: glossary.yml
    # Element: <g:doc_part_type>
    class DocPartType < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element 'doc_part_type'
        namespace Uniword::Ooxml::Namespaces::Glossary

        map_attribute 'val', to: :val
      end
    end
  end
end
