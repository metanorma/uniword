# frozen_string_literal: true

require 'lutaml/model'

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
      attribute :tab_stops, TabStop, collection: true, initialize_empty: true

      xml do
        element 'tabs'
        namespace Ooxml::Namespaces::WordProcessingML

        map_element 'tab', to: :tab_stops
      end

      # Delegate array operations to tab_stops
      def <<(tab_stop)
        tab_stops << tab_stop
      end

      def size
        tab_stops.size
      end

      def first
        tab_stops.first
      end

      def last
        tab_stops.last
      end

      def [](index)
        tab_stops[index]
      end

      def each(&)
        tab_stops.each(&)
      end

      def map(&)
        tab_stops.map(&)
      end

      def empty?
        tab_stops.empty?
      end
    end
  end
end
