# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Glossary
    # Unique identifier for a document part
    #
    # Generated from OOXML schema: glossary.yml
    # Element: <g:doc_part_id>
    class DocPartId < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element 'doc_part_id'
        namespace Uniword::Ooxml::Namespaces::Glossary

        map_attribute 'val', to: :val
      end
    end
  end
end
