# frozen_string_literal: true

require_relative '../ooxml/namespaces'

module Uniword
  module Properties
    # Individual tab stop definition
    class TabStop < Lutaml::Model::Serializable
      xml do
        element 'tab'
        namespace Ooxml::Namespaces::WordProcessingML

        map_attribute 'pos', to: :position
        map_attribute 'val', to: :alignment
        map_attribute 'leader', to: :leader
      end

      # Tab position in twips (1/20th of a point)
      attribute :position, :integer

      # Tab alignment (left, center, right, decimal, bar, num, clear)
      # Common values: left, center, right, decimal, bar
      attribute :alignment, :string, default: -> { 'left' }

      # Tab leader character (none, dot, hyphen, underscore, heavy, middleDot)
      # Common values: none, dot, hyphen, underscore
      attribute :leader, :string, default: -> { 'none' }

      # Convenience method to create a left-aligned tab stop
      def self.left(position, leader = 'none')
        new(position: position, alignment: 'left', leader: leader)
      end

      # Convenience method to create a center-aligned tab stop
      def self.center(position, leader = 'none')
        new(position: position, alignment: 'center', leader: leader)
      end

      # Convenience method to create a right-aligned tab stop
      def self.right(position, leader = 'none')
        new(position: position, alignment: 'right', leader: leader)
      end

      # Convenience method to create a decimal-aligned tab stop
      def self.decimal(position, leader = 'none')
        new(position: position, alignment: 'decimal', leader: leader)
      end

      # Convenience method to create a bar tab stop
      def self.bar(position)
        new(position: position, alignment: 'bar', leader: 'none')
      end

      # Convenience method to create a clear tab stop (removes existing tabs)
      def self.clear(position)
        new(position: position, alignment: 'clear', leader: 'none')
      end

      # Value-based equality
      def ==(other)
        return false unless other.is_a?(self.class)

        position == other.position &&
          alignment == other.alignment &&
          leader == other.leader
      end

      alias eql? ==

      # Hash code for value-based hashing
      def hash
        [position, alignment, leader].hash
      end
    end

    # Tab stop collection - manages multiple tab stops for a paragraph
    class TabStopCollection < Lutaml::Model::Serializable
      xml do
        element 'tabs'
        namespace Ooxml::Namespaces::WordProcessingML

        map_element 'tab', to: :tabs
      end

      # Collection of tab stops
      attribute :tabs, TabStop, collection: true, default: -> { [] }

      # Add a tab stop to the collection
      #
      # @param position [Integer] Tab position in twips
      # @param alignment [String] Tab alignment ('left', 'center', 'right', 'decimal', 'bar')
      # @param leader [String] Tab leader character ('none', 'dot', 'hyphen', 'underscore')
      # @return [TabStop] The created tab stop
      def add_tab(position, alignment = 'left', leader = 'none')
        tab = TabStop.new(position: position, alignment: alignment, leader: leader)
        tabs << tab
        tab
      end

      # Add multiple tab stops at once
      #
      # @param tab_definitions [Array<Array>] Array of [position, alignment, leader] arrays
      # @return [Array<TabStop>] Array of created tab stops
      def add_tabs(*tab_definitions)
        tab_definitions.map do |definition|
          position, alignment, leader = definition
          add_tab(position, alignment || 'left', leader || 'none')
        end
      end

      # Remove a tab stop by position
      #
      # @param position [Integer] Position of tab stop to remove
      # @return [TabStop, nil] The removed tab stop, or nil if not found
      def remove_tab(position)
        tab = tabs.find { |t| t.position == position }
        tabs.delete(tab) if tab
      end

      # Clear all tab stops
      #
      # @return [Array] Empty array
      def clear_tabs
        tabs.clear
      end

      # Get tab stops sorted by position
      #
      # @return [Array<TabStop>] Sorted array of tab stops
      def sorted_tabs
        tabs.sort_by(&:position)
      end

      # Check if collection has any tab stops
      #
      # @return [Boolean] true if has tab stops
      def any_tabs?
        !tabs.empty?
      end

      # Get count of tab stops
      #
      # @return [Integer] Number of tab stops
      def tab_count
        tabs.size
      end

      # Value-based equality
      def ==(other)
        return false unless other.is_a?(self.class)

        tabs == other.tabs
      end

      alias eql? ==

      # Hash code for value-based hashing
      def hash
        tabs.hash
      end
    end
  end
end