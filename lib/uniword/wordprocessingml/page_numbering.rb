# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Page numbering format
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:pgNumType>
    class PageNumbering < Lutaml::Model::Serializable
      attribute :format, :string
      attribute :fmt, :string
      attribute :start, :integer

      xml do
        element "pgNumType"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_attribute "format", to: :format, render_nil: false
        map_attribute "fmt", to: :fmt, render_nil: false
        map_attribute "start", to: :start, render_nil: false
      end
    end
  end
end
