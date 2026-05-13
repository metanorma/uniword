# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    class WrapIndent < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "wrapIndent"
        namespace Uniword::Ooxml::Namespaces::MathML
        map_attribute "val", to: :val
      end
    end
  end
end
