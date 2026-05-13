# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    class DispDef < Lutaml::Model::Serializable
      xml do
        element "dispDef"
        namespace Uniword::Ooxml::Namespaces::MathML
      end
    end
  end
end
