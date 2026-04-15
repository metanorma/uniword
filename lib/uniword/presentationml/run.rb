# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Presentationml
    # Run of text with consistent formatting
    #
    # Generated from OOXML schema: presentationml.yml
    # Element: <p:r>
    class Run < Lutaml::Model::Serializable
      attribute :r_pr, RunProperties
      attribute :t, :string

      xml do
        element "r"
        namespace Uniword::Ooxml::Namespaces::PresentationalML
        mixed_content

        map_element "rPr", to: :r_pr, render_nil: false
        map_element "t", to: :t, render_nil: false
      end
    end
  end
end
