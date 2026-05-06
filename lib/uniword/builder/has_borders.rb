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
          props.borders.send("#{side}=", border)
        end
        self
      end
    end
  end
end
