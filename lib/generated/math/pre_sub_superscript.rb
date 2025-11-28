# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Math
      # Pre-subscript and superscript object
      #
      # Generated from OOXML schema: math.yml
      # Element: <m:sPre>
      class PreSubSuperscript < Lutaml::Model::Serializable
          attribute :properties, PreSubSuperscriptProperties
          attribute :sub, Sub
          attribute :sup, Sup
          attribute :element, Element

          xml do
            root 'sPre'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/math', 'm'
            mixed_content

            map_element 'sPrePr', to: :properties, render_nil: false
            map_element 'sub', to: :sub
            map_element 'sup', to: :sup
            map_element 'e', to: :element
          end
      end
    end
  end
end
