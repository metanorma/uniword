# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Math
    # Matrix column formatting properties
    #
    # Generated from OOXML schema: math.yml
    # Element: <m:mcPr>
    class MatrixColumnProperties < Lutaml::Model::Serializable
      attribute :count, :integer
      attribute :column_jc, :string

      xml do
        element "mcPr"
        namespace Uniword::Ooxml::Namespaces::MathML

        map_attribute "val", to: :count
        map_attribute "val", to: :column_jc
      end
    end
  end
end
