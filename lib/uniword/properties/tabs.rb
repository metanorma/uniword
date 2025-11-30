# frozen_string_literal: true

require 'lutaml/model'
require_relative 'tab_stop'

module Uniword
  module Properties
    # Tab stops collection
    #
    # Represents <w:tabs> element containing multiple tab stop definitions.
    #
    # @example Creating tab stops
    #   tabs = Tabs.new(
    #     tab_stops: [
    #       TabStop.new(alignment: 'left', position: 720),
    #       TabStop.new(alignment: 'center', position: 1440),
    #       TabStop.new(alignment: 'right', position: 2160)
    #     ]
    #   )
    class Tabs < Lutaml::Model::Serializable
      # Pattern 0: ATTRIBUTES FIRST
      attribute :tab_stops, TabStop, collection: true

      xml do
        element 'tabs'
        namespace Ooxml::Namespaces::WordProcessingML

        map_element 'tab', to: :tab_stops
      end
    end
  end
end