# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Sdt
    # Document part reference for placeholder
    # Reference XML: <w:docPart w:val="{F765B1B1-...}"/>
    class DocPartReference < Lutaml::Model::Serializable
      attribute :value, :string

      xml do
        element 'docPart'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute 'val', to: :value
      end
    end

    # Placeholder for Structured Document Tag
    # Reference XML: <w:placeholder><w:docPart w:val="{...}"/></w:placeholder>
    class Placeholder < Lutaml::Model::Serializable
      attribute :doc_part, DocPartReference

      xml do
        element 'placeholder'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_element 'docPart', to: :doc_part
      end
    end
  end
end
