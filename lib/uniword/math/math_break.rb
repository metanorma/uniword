# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Math
    # Break in math equation
    #
    # Generated from OOXML schema: math.yml
    # Element: <m:brk>
    class MathBreak < Lutaml::Model::Serializable
      attribute :aln_at, :integer

      xml do
        element "brk"
        namespace Uniword::Ooxml::Namespaces::MathML

        map_attribute "val", to: :aln_at
      end
    end
  end
end
