# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Title page / different first page toggle
    # Reference XML: <w:titlePg/>
    # Empty element that enables different first page header/footer
    class TitlePg < Lutaml::Model::Serializable
      attribute :val, :string, default: nil

      xml do
        element "titlePg"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "val", to: :val, render_nil: false
      end
    end
  end
end
