# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Update fields when the document is opened
    #
    # Element: <w:updateFields>
    #
    # When on, Word updates all fields (TOC, page numbers, cross
    # references) the first time the document is opened — generated
    # documents show correct field values without a manual F9.
    #
    # This reads through the same ST_OnOff element machinery as every other
    # toggle. It used to go through Ooxml::Types::OoxmlBoolean, a second
    # definition that raised on a malformed w:val and disagreed about nil.
    class UpdateFields < Lutaml::Model::Serializable
      include Uniword::Properties::BooleanElement

      attribute :val, :string, default: nil
      include Uniword::Properties::BooleanValSetter

      xml do
        element "updateFields"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_attribute "val", to: :val, render_nil: false,
                             render_default: false
      end
    end
  end
end
