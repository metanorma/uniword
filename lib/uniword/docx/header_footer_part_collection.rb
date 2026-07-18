# frozen_string_literal: true

module Uniword
  module Docx
    # Ordered collection of HeaderFooterPart objects — the single
    # storage path for all header/footer parts of a document, whether
    # loaded from an existing DOCX or added programmatically.
    #
    # The +headers+/+footers+ views (HeaderFooterView) and the
    # serializer both read from this store, so a part exists exactly
    # once: one part file, one relationship, one content-type
    # override, one sectPr reference.
    class HeaderFooterPartCollection
      include Enumerable

      def initialize
        @parts = []
      end

      # Iterate over all parts (both kinds) in insertion order.
      def each(&block)
        @parts.each(&block)
      end

      # @return [Integer]
      def size
        @parts.size
      end

      alias length size

      # @return [Boolean]
      def empty?
        @parts.empty?
      end

      # @return [Array<HeaderFooterPart>]
      def to_a
        @parts.dup
      end

      # Append a part.
      #
      # @param part [HeaderFooterPart]
      # @return [HeaderFooterPart] the added part
      def <<(part)
        @parts << part
        part
      end

      alias add <<

      # Remove a part (by identity).
      #
      # @param part [HeaderFooterPart]
      # @return [HeaderFooterPart, nil] the removed part
      def delete(part)
        @parts.delete(part)
      end

      # @param kind [Symbol] :header or :footer
      # @return [Array<HeaderFooterPart>] parts of that kind, in order
      def of_kind(kind)
        @parts.select { |part| part.kind == kind }
      end

      # @param kind [Symbol] :header or :footer
      # @param type [String, nil] sectPr reference type
      # @return [HeaderFooterPart, nil]
      def find_part(kind, type)
        type = type&.to_s
        @parts.find { |part| part.kind == kind && part.type == type }
      end

      # All non-nil relationship targets in the store.
      #
      # @return [Array<String>]
      def targets
        @parts.filter_map(&:target)
      end

      # First unused numbered target for a kind
      # ("header3.xml" when header1/header2 exist).
      #
      # @param kind [Symbol] :header or :footer
      # @return [String]
      def next_target(kind)
        numbers = of_kind(kind).filter_map do |part|
          part.target&.[](/\A#{kind}(\d+)\.xml\z/, 1)&.to_i
        end
        "#{kind}#{(numbers.max || 0) + 1}.xml"
      end

      # Replace the entire store (legacy +header_footer_parts=+
      # assignment). Accepts HeaderFooterPart objects and legacy
      # part hashes ({ r_id:, target:, rel_type:, content_type:,
      # content: }).
      #
      # @param parts [Array<HeaderFooterPart, Hash>]
      # @return [void]
      def replace_all(parts)
        @parts = Array(parts).map { |part| self.class.wrap(part) }
      end

      # Replace all parts of one kind, leaving the other untouched.
      #
      # @param kind [Symbol] :header or :footer
      # @param parts [Array<HeaderFooterPart>]
      # @return [void]
      def replace_kind(kind, parts)
        @parts.reject! { |part| part.kind == kind }
        parts.each { |part| @parts << part }
      end

      # Normalize one entry into a HeaderFooterPart. Legacy hashes
      # describe loaded parts (they carry original rIds/targets).
      #
      # @param value [HeaderFooterPart, Hash]
      # @return [HeaderFooterPart]
      def self.wrap(value)
        return value if value.is_a?(HeaderFooterPart)

        HeaderFooterPart.new(
          r_id: value[:r_id],
          target: value[:target],
          rel_type: value[:rel_type],
          content_type: value[:content_type],
          type: value[:type],
          content: value[:content],
          loaded: true,
        )
      end
    end
  end
end
