# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Math
      # Mathematical fraction
      #
      # Generated from OOXML schema: math.yml
      # Element: <m:f>
      class Fraction < Lutaml::Model::Serializable
          attribute :properties, FractionProperties
          attribute :numerator, Numerator
          attribute :denominator, Denominator

          xml do
            root 'f'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/math', 'm'
            mixed_content

            map_element 'fPr', to: :properties, render_nil: false
            map_element 'num', to: :numerator
            map_element 'den', to: :denominator
          end
      end
    end
  end
end
