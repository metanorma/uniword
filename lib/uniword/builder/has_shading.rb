# frozen_string_literal: true

module Uniword
  module Builder
    # Mixin for builders that support shading configuration.
    #
    # Expects the including class to implement #ensure_properties
    # returning the properties object that has a #shading= setter.
    module HasShading
      def shading(fill:, color: nil, pattern: "clear")
        props = ensure_properties
        props.shading = Properties::Shading.new(
          fill: fill, color: color, pattern: pattern,
        )
        self
      end
    end
  end
end
