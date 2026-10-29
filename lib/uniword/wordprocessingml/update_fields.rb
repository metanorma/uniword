# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Update fields when the document is opened
    #
    # Element: <w:updateFields>
    #
    # When true, Word updates all fields (TOC, page numbers, cross
    # references) the first time the document is opened — generated
    # documents show correct field values without a manual F9.
    class UpdateFields < Lutaml::Model::Serializable
      attribute :value, Ooxml::Types::OoxmlBoolean,
                default: -> { true }

      xml do
        element "updateFields"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_attribute "val", to: :value, render_nil: false,
                                        render_default: false
      end
    end
  end
end
