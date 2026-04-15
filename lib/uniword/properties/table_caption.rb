# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Properties
    # Table caption
    # Reference XML: <w:tblCaption w:val="Sample 5-column table"/>
    class TableCaption < Lutaml::Model::Serializable
      attribute :value, :string

      xml do
        element "tblCaption"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "val", to: :value, render_nil: false
      end
    end
  end
end
