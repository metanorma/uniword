# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Math
      # Subscript and superscript object
      #
      # Generated from OOXML schema: math.yml
      # Element: <m:sSubSup>
      class SubSuperscript < Lutaml::Model::Serializable
          attribute :properties, SubSuperscriptProperties
          attribute :element, Element
          attribute :sub, Sub
          attribute :sup, Sup

          xml do
            root 'sSubSup'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/math', 'm'
            mixed_content

            map_element 'sSubSupPr', to: :properties, render_nil: false
            map_element 'e', to: :element
            map_element 'sub', to: :sub
            map_element 'sup', to: :sup
          end
      end
    end
  end
end
