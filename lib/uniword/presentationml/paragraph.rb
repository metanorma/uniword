# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Presentationml
    # Paragraph of text within a text body
    #
    # Generated from OOXML schema: presentationml.yml
    # Element: <p:p>
    class Paragraph < Lutaml::Model::Serializable
      attribute :p_pr, ParagraphProperties
      attribute :r, Run, collection: true, initialize_empty: true
      attribute :br, Break, collection: true, initialize_empty: true
      attribute :fld, Field, collection: true, initialize_empty: true
      attribute :end_para_r_pr, RunProperties

      xml do
        element "p"
        namespace Uniword::Ooxml::Namespaces::PresentationalML
        mixed_content

        map_element "pPr", to: :p_pr, render_nil: false
        map_element "r", to: :r, render_nil: false
        map_element "br", to: :br, render_nil: false
        map_element "fld", to: :fld, render_nil: false
        map_element "endParaRPr", to: :end_para_r_pr, render_nil: false
      end
    end
  end
end
