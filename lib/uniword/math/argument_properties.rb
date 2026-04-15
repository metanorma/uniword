# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Math
    # Argument properties for math structures
    #
    # Generated from OOXML schema: math.yml
    # Element: <m:argPr>
    class ArgumentProperties < Lutaml::Model::Serializable
      attribute :arg_size, :integer

      xml do
        element "argPr"
        namespace Uniword::Ooxml::Namespaces::MathML

        map_attribute "val", to: :arg_size
      end
    end
  end
end
