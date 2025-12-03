# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Structured document tag content container
    # Reference XML: <w:sdtContent>...</w:sdtContent>
    class SdtContent < Lutaml::Model::Serializable
      attribute :paragraphs, Paragraph, collection: true, default: -> { [] }
      attribute :tables, Table, collection: true, default: -> { [] }
      attribute :runs, Run, collection: true, default: -> { [] }
      attribute :alternate_content, AlternateContent, default: nil

      xml do
        element 'sdtContent'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_element 'p', to: :paragraphs, render_nil: false
        map_element 'tbl', to: :tables, render_nil: false
        map_element 'r', to: :runs, render_nil: false
        map_element 'AlternateContent', to: :alternate_content, render_nil: false
      end
    end
  end
end