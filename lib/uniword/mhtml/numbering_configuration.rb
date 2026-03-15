# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Mhtml
    # MHTML-specific Numbering Configuration class
    #
    # This is SEPARATE from OOXML WordprocessingML NumberingConfiguration.
    # MHTML uses HTML/CSS list styling, not OOXML numbering parts.
    #
    # This class manages numbering/list definitions for MHTML documents
    # and provides CSS list styling for MHTML serialization.
    class NumberingConfiguration < Lutaml::Model::Serializable
      attribute :lists, :hash, default: -> { {} }
      attribute :counters, :hash, default: -> { {} }

      # MHTML-specific: Convert numbering to CSS
      #
      # @return [String] CSS list styling
      def to_css
        css = +''
        lists.each do |name, config|
          list_type = config['type'] || 'decimal'
          css << ".list-#{name} {\n"
          css << "  list-style-type: #{list_type};\n"
          css << "}\n\n"
        end
        css
      end

      # MHTML-specific: Get list configuration
      #
      # @param name [String] List name
      # @return [Hash, nil] List configuration
      def list(name)
        lists[name.to_s]
      end

      # MHTML-specific: Add a list configuration
      #
      # @param name [String] List name
      # @param config [Hash] List configuration (type, start, etc.)
      def add_list(name, config)
        lists[name.to_s] = config
      end
    end
  end
end
