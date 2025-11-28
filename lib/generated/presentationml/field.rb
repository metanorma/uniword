# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Presentationml
      # Field element (date, slide number, etc.)
      #
      # Generated from OOXML schema: presentationml.yml
      # Element: <p:fld>
      class Field < Lutaml::Model::Serializable
          attribute :id, :string
          attribute :type, :string
          attribute :r_pr, RunProperties
          attribute :p_pr, ParagraphProperties
          attribute :t, :string

          xml do
            root 'fld'
            namespace 'http://schemas.openxmlformats.org/presentationml/2006/main', 'p'
            mixed_content

            map_attribute 'id', to: :id
            map_attribute 'type', to: :type
            map_element 'rPr', to: :r_pr, render_nil: false
            map_element 'pPr', to: :p_pr, render_nil: false
            map_element 't', to: :t, render_nil: false
          end
      end
    end
  end
end
