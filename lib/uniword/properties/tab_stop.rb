# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Properties
    # Tab alignment enumeration
    #
    # Represents alignment types for tab stops
    class TabAlignmentValue < Lutaml::Model::Type::String
      xml_namespace Ooxml::Namespaces::WordProcessingML
    end

    # Tab leader enumeration
    #
    # Represents leader character styles for tab stops
    class TabLeaderValue < Lutaml::Model::Type::String
      xml_namespace Ooxml::Namespaces::WordProcessingML
    end

    # Individual tab stop definition
    #
    # Represents a single tab stop with alignment, position, and leader.
    #
    # @example Creating a tab stop
    #   tab = TabStop.new(
    #     alignment: 'left',
    #     position: 720,
    #     leader: 'dot'
    #   )
    class TabStop < Lutaml::Model::Serializable
      # Pattern 0: ATTRIBUTES FIRST
      attribute :alignment, TabAlignmentValue
      attribute :position, :integer # Position in twips
      attribute :leader, TabLeaderValue

      xml do
        element 'tab'
        namespace Ooxml::Namespaces::WordProcessingML

        map_attribute 'val', to: :alignment
        map_attribute 'pos', to: :position
        map_attribute 'leader', to: :leader
      end
    end
  end
end
