# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Header content
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:hdr>
      class Header < Lutaml::Model::Serializable
          attribute :paragraphs, Paragraph, collection: true, default: -> { [] }
          attribute :tables, Table, collection: true, default: -> { [] }

          xml do
            root 'hdr'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'
            mixed_content

            map_element 'p', to: :paragraphs, render_nil: false
            map_element 'tbl', to: :tables, render_nil: false
          end
      end
    end
  end
end
