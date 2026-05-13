# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Document variable entry
    #
    # Element: <w:docVar>
    class DocVar < Lutaml::Model::Serializable
      attribute :name, :string
      attribute :val, :string

      xml do
        element "docVar"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "name", to: :name
        map_attribute "val", to: :val
      end
    end

    # Document variables container
    #
    # Element: <w:docVars>
    class DocVars < Lutaml::Model::Serializable
      attribute :doc_var, DocVar, collection: true

      xml do
        element "docVars"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content
        map_element "docVar", to: :doc_var, render_nil: false
      end
    end
  end
end
