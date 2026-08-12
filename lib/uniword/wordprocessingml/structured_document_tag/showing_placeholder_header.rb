# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    class StructuredDocumentTag
      # Showing placeholder header flag for Structured Document Tag
      # Reference XML: <w:showingPlcHdr/> or <w:showingPlcHdr w:val="0"/>
      #
      # This is an ST_OnOff toggle like every other one. It used to map no
      # w:val at all, so an explicitly-off flag round-tripped as on and the
      # four spellings were indistinguishable.
      class ShowingPlaceholderHeader < Lutaml::Model::Serializable
        include Uniword::Properties::BooleanElement

        attribute :val, :string, default: nil
        include Uniword::Properties::BooleanValSetter

        xml do
          element "showingPlcHdr"
          namespace Ooxml::Namespaces::WordProcessingML
          map_attribute "val", to: :val, render_nil: false,
                               render_default: false
        end
      end
    end
  end
end
