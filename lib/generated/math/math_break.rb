# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Math
      # Break in math equation
      #
      # Generated from OOXML schema: math.yml
      # Element: <m:brk>
      class MathBreak < Lutaml::Model::Serializable
          attribute :aln_at, Integer

          xml do
            root 'brk'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/math', 'm'

            map_attribute 'val', to: :aln_at
          end
      end
    end
  end
end
