# frozen_string_literal: true

module Uniword
  module Docx
    # Kind-filtered view over a document's HeaderFooterPartCollection.
    #
    # +document.headers+ and +document.footers+ return these views, so
    # the Builder, the headers/footers managers and the serializer all
    # share the single underlying store.
    #
    # Two historic access shapes are preserved:
    # - Hash-style (Builder): +view["default"] = header_model+,
    #   +view["default"]+, +each_value+, +values+, +keys+, +key?+,
    #   +delete+. Content access yields the Header/Footer models.
    # - Array-style (managers): +view << header+, +each+, +map+,
    #   +find+, +reject+. Iteration yields HeaderFooterPart objects,
    #   which carry the sectPr +type+ and delegate +paragraphs+,
    #   +tables+ and +empty?+ to their content.
    #
    # Upsert semantics: assigning a type that already exists replaces
    # that part's content in place (keeping its target and rId), so
    # loaded and builder-created parts can never duplicate.
    class HeaderFooterView
      include Enumerable

      # @return [Symbol] :header or :footer
      attr_reader :kind

      # @param store [HeaderFooterPartCollection] the unified store
      # @param kind [Symbol] :header or :footer
      def initialize(store, kind)
        @store = store
        @kind = kind
      end

      # Iterate over the parts of this kind (Array-style access).
      def each(&block)
        @store.of_kind(kind).each(&block)
      end

      # Hash-style read: content model for a sectPr type.
      #
      # @param type [String, Symbol] "default"/"first"/"even"
      # @return [Wordprocessingml::Header, Wordprocessingml::Footer, nil]
      def [](type)
        @store.find_part(kind, type)&.content
      end

      # Hash-style write: upsert a content model by sectPr type.
      # Replaces the existing part's content in place when the type
      # exists; otherwise appends a new part with the next free
      # numbered target.
      #
      # @param type [String, Symbol] sectPr reference type
      # @param model [Object] Wordprocessingml::Header/Footer or
      #   legacy Uniword::Header/Footer
      # @return [Object] the assigned model
      def []=(type, model)
        type = type.to_s
        content = coerce_content(model)
        part = @store.find_part(kind, type)
        if part
          part.content = content
          part.loaded = false
        else
          @store << HeaderFooterPart.new(
            kind: kind, type: type, content: content,
            target: @store.next_target(kind)
          )
        end
        model
      end

      # Append a model (Array-style). Legacy Uniword::Header/Footer
      # models supply their own +type+; other models are stored
      # without a type.
      #
      # @param model [Object] content model or HeaderFooterPart
      # @return [Object] the appended model
      def <<(model)
        if model.is_a?(HeaderFooterPart)
          adopt_part(model)
        else
          append_model(model)
        end
        model
      end

      # Iterate over sectPr types.
      def each_key(&block)
        map(&:type).each(&block)
      end

      # Iterate over content models.
      def each_value(&block)
        map(&:content).each(&block)
      end

      # @return [Array<String, nil>] sectPr types
      def keys
        map(&:type)
      end

      # @return [Array] content models
      def values
        map(&:content)
      end

      # @param type [String, Symbol]
      # @return [Boolean]
      def key?(type)
        !@store.find_part(kind, type).nil?
      end

      # Remove the part for a sectPr type.
      #
      # @param type [String, Symbol]
      # @return [Object, nil] the removed part's content
      def delete(type)
        part = @store.find_part(kind, type)
        return nil unless part

        @store.delete(part)
        part.content
      end

      # @return [Integer]
      def size
        @store.of_kind(kind).size
      end

      # @return [Boolean]
      def empty?
        size.zero?
      end

      # Bulk assignment (+document.headers = value+). Accepts nil
      # (clears this kind), a Hash of type => model, an Array of
      # models/parts, or the view itself (no-op).
      #
      # @param value [nil, Hash, Array, HeaderFooterView]
      # @return [Object] the assigned value
      def replace(value)
        case value
        when nil then @store.replace_kind(kind, [])
        when HeaderFooterView then nil
        when Hash then replace_from_hash(value)
        when Array then replace_from_array(value)
        else
          raise ArgumentError,
                "cannot assign #{value.class} to document.#{kind}s"
        end
        value
      end

      private

      def adopt_part(part)
        part.target ||= @store.next_target(part.kind || kind)
        @store << part
      end

      def append_model(model)
        type = legacy_type(model)
        return self[type] = model if type

        @store << HeaderFooterPart.new(
          kind: kind, content: coerce_content(model),
          target: @store.next_target(kind)
        )
      end

      def replace_from_hash(hash)
        hash.each { |type, model| self[type] = model }
        kept = hash.keys.map(&:to_s)
        @store.of_kind(kind).each do |part|
          @store.delete(part) if stale_fresh_part?(part, kept)
        end
      end

      # A programmatically-added part is stale after a Hash assignment
      # when its type is not among the assigned keys (loaded parts are
      # never removed by view assignment).
      def stale_fresh_part?(part, kept_types)
        !part.loaded? && !part.type.nil? && !kept_types.include?(part.type)
      end

      def replace_from_array(array)
        parts = array.map { |entry| coerce_to_part(entry) }
        @store.replace_kind(kind, [])
        parts.each do |part|
          part.target ||= @store.next_target(kind)
          @store << part
        end
      end

      def coerce_to_part(entry)
        case entry
        when HeaderFooterPart then entry
        when Hash then HeaderFooterPartCollection.wrap(entry)
        else
          HeaderFooterPart.new(
            kind: kind, type: legacy_type(entry),
            content: coerce_content(entry)
          )
        end
      end

      # Legacy Uniword::Header/Footer carry their sectPr type.
      def legacy_type(model)
        case model
        when Uniword::Header, Uniword::Footer then model.type
        end
      end

      # Content is stored as given: legacy Uniword::Header/Footer
      # models stay live (callers may keep mutating them) and are
      # converted to their Wordprocessingml counterparts only at
      # serialization time (HeaderFooterPart#serializable_content).
      def coerce_content(model)
        model
      end
    end
  end
end
