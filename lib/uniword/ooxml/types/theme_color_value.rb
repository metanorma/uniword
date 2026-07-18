# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Ooxml
    module Types
      # ST_ThemeColor (ECMA-376, wml.xsd): theme color reference
      #
      # Carries the full ST_ThemeColor enumeration so models can declare
      # `values: ThemeColorValue::VALUES` on theme color attributes.
      class ThemeColorValue < Lutaml::Model::Type::String
        # Full ST_ThemeColor enumeration from ECMA-376 (wml.xsd)
        VALUES = %w[
          dark1 light1 dark2 light2 accent1 accent2 accent3 accent4
          accent5 accent6 hyperlink followedHyperlink none background1
          text1 background2 text2
        ].freeze
      end
    end
  end
end
