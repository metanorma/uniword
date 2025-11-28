# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Style definition
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:style>
      class Style < Lutaml::Model::Serializable
          attribute :type, :string
          attribute :styleId, :string
          attribute :default, :boolean
          attribute :customStyle, :boolean
          attribute :name, StyleName
          attribute :basedOn, BasedOn
          attribute :next, Next
          attribute :link, Link
          attribute :uiPriority, UiPriority
          attribute :qFormat, :boolean
          attribute :pPr, ParagraphProperties
          attribute :rPr, RunProperties
          attribute :tblPr, TableProperties
          attribute :tcPr, TableCellProperties

          xml do
            root 'style'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'
            mixed_content

            map_attribute 'true', to: :type
            map_attribute 'true', to: :styleId
            map_attribute 'true', to: :default
            map_attribute 'true', to: :customStyle
            map_element 'name', to: :name, render_nil: false
            map_element 'basedOn', to: :basedOn, render_nil: false
            map_element 'next', to: :next, render_nil: false
            map_element 'link', to: :link, render_nil: false
            map_element 'uiPriority', to: :uiPriority, render_nil: false
            map_element 'qFormat', to: :qFormat, render_nil: false
            map_element 'pPr', to: :pPr, render_nil: false
            map_element 'rPr', to: :rPr, render_nil: false
            map_element 'tblPr', to: :tblPr, render_nil: false
            map_element 'tcPr', to: :tcPr, render_nil: false
          end
      end
    end
  end
end
