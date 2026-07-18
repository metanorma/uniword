# frozen_string_literal: true

module Uniword
  module Docx
    # A chart part (word/charts/chartN.xml) held by the package.
    #
    # The content is the raw chart XML String. Replaces the former
    # +{ xml:, target: }+ hash entries in +chart_parts+.
    class ChartPart < Part
      # @param r_id [String, nil] relationship id
      # @param target [String, nil] e.g. "charts/chart1.xml"
      # @param content [String, nil] raw chart XML
      def initialize(r_id: nil, target: nil, content: nil, **rest)
        super(
          definition: Ooxml::PartRegistry.find_by_key(:chart),
          r_id: r_id, target: target, content: content, **rest
        )
      end

      # Raw chart XML (alias for content).
      #
      # @return [String, nil]
      def xml
        content
      end

      # Hash-style read compatibility (+:xml+ in addition to the
      # Part keys).
      def [](key)
        key.to_sym == :xml ? content : super
      end
    end
  end
end
