# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    class StructuredDocumentTag
      # Temporary flag for Structured Document Tag
      # Indicates the SDT should be removed when content is first edited
      # Reference XML: <w:temporary/> or <w:temporary w:val="0"/>
      #
      # This is an ST_OnOff toggle like every other one. It used to map no
      # w:val at all, so an explicitly-off flag round-tripped as on and the
      # six spellings were indistinguishable.
      class Temporary < Lutaml::Model::Serializable
        include Uniword::Properties::BooleanElement

        attribute :val, :string, default: nil
        include Uniword::Properties::BooleanValSetter

        xml do
          element "temporary"
          namespace Ooxml::Namespaces::WordProcessingML
          map_attribute "val", to: :val, render_nil: false,
                               render_default: false
        end
      end
    end
  end
end
