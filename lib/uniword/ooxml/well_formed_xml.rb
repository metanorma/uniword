# frozen_string_literal: true

require "rexml/document"

module Uniword
  module Ooxml
    # Strict XML well-formedness verification.
    #
    # The default engine parse recovers silently on this stack
    # (moxml#385: parse(strict: true) is not honored), so
    # well-formedness gates detect malformation with REXML, which
    # raises on structural errors the recovering engines auto-close.
    module WellFormedXml
      # Raise when +xml+ is not well-formed.
      #
      # @param xml [String] XML content
      # @return [void]
      # @raise [Moxml::ParseError] mirroring the engine parse error
      #   contract so callers' existing rescues keep working
      def self.verify!(xml)
        REXML::Document.new(xml)
      rescue REXML::ParseException => e
        raise Moxml::ParseError,
              "Malformed XML: #{e.message.lines.first.to_s.strip}"
      end
    end
  end
end
