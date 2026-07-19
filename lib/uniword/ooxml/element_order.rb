# frozen_string_literal: true

module Uniword
  module Ooxml
    # Safe mutation of lutaml-model `element_order` arrays.
    #
    # lutaml-model freezes `element_order` on parsed models; mutating
    # it raises FrozenError. These helpers thaw on demand (dup +
    # assign back) and insert entries in schema position — the single
    # mechanism for the whole library, not a monkey-patch.
    #
    # @example Thaw and append
    #   order = Ooxml::ElementOrder.mutable_order(footnotes)
    #   order << Lutaml::Xml::Element.new("Element", "footnote")
    #
    # @example Idempotent singleton insert
    #   Ooxml::ElementOrder.insert_once(settings, "updateFields",
    #                                    after: "characterSpacingControl")
    module ElementOrder
      # Return the model's element_order as a mutable array.
      #
      # The frozen parsed array is replaced by a dup assigned back to
      # the model; already-mutable arrays are returned as-is (so
      # repeated calls keep mutating the same registered array).
      #
      # @param model [Lutaml::Model::Serializable] model to thaw
      # @return [Array, nil] mutable element_order, or nil when the
      #   model carries none
      def mutable_order(model)
        order = model.element_order
        return unless order
        return order unless order.frozen?

        model.element_order = order.dup
      end
      module_function :mutable_order

      # Append an entry (repeatable elements allowed).
      #
      # @param model [Lutaml::Model::Serializable] model to mutate
      # @param entry [Lutaml::Xml::Element] entry to append
      # @return [Array, nil] the mutated order
      def append(model, entry)
        mutable_order(model)&.<<(entry)
      end
      module_function :append

      # Insert an entry at an index (repeatable elements allowed).
      #
      # @param model [Lutaml::Model::Serializable] model to mutate
      # @param position [Integer] insertion index
      # @param entry [Lutaml::Xml::Element] entry to insert
      # @return [Array, nil] the mutated order
      def insert_at(model, position, entry)
        mutable_order(model)&.insert(position, entry)
      end
      module_function :insert_at

      # Insert a singleton element in schema position, by name.
      # Idempotent: no-op when an entry of that name already exists.
      # Missing anchors fall back to end (after:) or start (before:).
      #
      # @param model [Lutaml::Model::Serializable] model to mutate
      # @param name [String] element name to insert
      # @param after [String, nil] insert after this element name
      # @param before [String, nil] insert before this element name
      # @param position [Integer, nil] explicit index (when neither
      #   after nor before is given; defaults to end)
      # @return [Array, nil] the mutated order
      def insert_once(model, name, after: nil, before: nil, position: nil)
        order = mutable_order(model)
        return unless order
        return if order.any? { |e| e.name == name }

        idx = insertion_index(order, after, before, position)
        order.insert(idx, Lutaml::Xml::Element.new("Element", name))
      end
      module_function :insert_once

      # @return [Integer] index for the insert
      def insertion_index(order, after, before, position)
        if after
          anchor = order.index { |e| e.name == after }
          anchor ? anchor + 1 : order.size
        elsif before
          order.index { |e| e.name == before } || 0
        else
          position || order.size
        end
      end
      module_function :insertion_index
    end
  end
end
