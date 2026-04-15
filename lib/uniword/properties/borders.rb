# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Properties
    # Paragraph borders container
    #
    # Represents <w:pBdr> element containing top, bottom, left, and right
    # border definitions.
    #
    # @example Creating borders
    #   borders = Borders.new(
    #     top: Border.new(style: 'single', size: 4, color: 'auto'),
    #     bottom: Border.new(style: 'single', size: 4, color: 'auto')
    #   )
    class Borders < Lutaml::Model::Serializable
      # Pattern 0: ATTRIBUTES FIRST
      attribute :top, Border
      attribute :bottom, Border
      attribute :left, Border
      attribute :right, Border
      attribute :between, Border
      attribute :bar, Border

      xml do
        element "pBdr"
        namespace Ooxml::Namespaces::WordProcessingML

        map_element "top", to: :top, render_nil: false
        map_element "bottom", to: :bottom, render_nil: false
        map_element "left", to: :left, render_nil: false
        map_element "right", to: :right, render_nil: false
        map_element "between", to: :between, render_nil: false
        map_element "bar", to: :bar, render_nil: false
      end
    end
  end
end
