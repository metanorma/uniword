# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Ooxml
    module Types
      module VariantTypes
        # String type for qualified vt: attributes (e.g. baseType on
        # vector elements).
        class VtAttr < Lutaml::Model::Type::String
          xml do
            namespace VT_NS
          end
        end
      end
    end
  end
end
