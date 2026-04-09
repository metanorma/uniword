# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Tab stop definition
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:tabStop>
    class TabStop < Lutaml::Model::Serializable
      attribute :val, :string
      attribute :pos, :integer
      attribute :leader, :string

      xml do
        element 'tabStop'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_attribute 'val', to: :val
        map_attribute 'pos', to: :pos
        map_attribute 'leader', to: :leader
      end

      # Get tab alignment
      #
      # @return [String, nil] Alignment value (left, center, right, decimal)
      def alignment
        val
      end

      # Set tab alignment
      #
      # @param value [String, Symbol] Alignment value
      # @return [String] The alignment that was set
      def alignment=(value)
        self.val = value.to_s
        value
      end

      # Get tab position
      #
      # @return [Integer, nil] Position in twips
      def position
        pos
      end

      # Set tab position
      #
      # @param value [Integer] Position in twips
      # @return [Integer] The position that was set
      def position=(value)
        self.pos = value
        value
      end
    end
  end
end
