# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Endnote definition
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:endnote>
      class Endnote < Lutaml::Model::Serializable
          attribute :id, :string
          attribute :type, :string
          attribute :paragraphs, Paragraph, collection: true, default: -> { [] }

          xml do
            root 'endnote'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'
            mixed_content

            map_attribute 'true', to: :id
            map_attribute 'true', to: :type
            map_element 'p', to: :paragraphs, render_nil: false
          end
      end
    end
  end
end
