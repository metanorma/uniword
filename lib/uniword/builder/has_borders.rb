# frozen_string_literal: true

module Uniword
  module Builder
    # Mixin for builders that support border configuration.
    #
    # Expects the including class to implement #ensure_properties
    # returning the properties object that has a #borders accessor.
    module HasBorders
      def borders(**sides)
        props = ensure_properties
        props.borders ||= Properties::Borders.new
        sides.each do |side, value|
          border = if value.is_a?(Hash)
                     Properties::Border.new(**value)
                   else
                     Properties::Border.new(color: value, style: "single",
                                            size: 4)
                   end
          case side
          when :top     then props.borders.top = border
          when :bottom  then props.borders.bottom = border
          when :left    then props.borders.left = border
          when :right   then props.borders.right = border
          when :between then props.borders.between = border
          when :bar     then props.borders.bar = border
          end
        end
        self
      end
    end
  end
end
