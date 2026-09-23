# frozen_string_literal: true

module Uniword
  module Review
    # Bridges parsed tracked-change nodes (<w:ins>/<w:del> on
    # paragraphs) to the TrackedChanges facade and applies
    # accept/reject decisions to the document models.
    #
    # Hydration walks the body (tables and SDT content included, via
    # ParagraphWalker) and registers one facade Revision per node,
    # keyed by the OOXML revision id (w:id). Decisions then mutate
    # the models:
    #
    # - accept insert  → splice wrapped runs into the paragraph
    # - reject insert  → remove the node
    # - accept delete  → remove the node (deleted content goes away)
    # - reject delete  → splice runs back, delText converted to t
    #
    # element_order arrays are updated alongside the collections so
    # serialization keeps the runs at the revision's position.
    class RevisionResolver
      # @param document [Wordprocessingml::DocumentRoot]
      def initialize(document)
        @document = document
        @nodes = {}
      end

      # Register every parsed ins/del node on the facade.
      #
      # @param tracked_changes [Uniword::TrackedChanges]
      # @return [Uniword::TrackedChanges]
      def hydrate(tracked_changes)
        each_tracked_node do |paragraph, node|
          id = node.id.to_s
          next if id.empty? || @nodes.key?(id)

          @nodes[id] = [paragraph, node]
          tracked_changes.add_revision(facade_revision_for(node))
        end
        tracked_changes
      end

      # Registered revision ids, in document order.
      #
      # @return [Array<String>]
      def ids
        @nodes.keys
      end

      # Accept one revision: keep inserted content / drop deleted
      # content.
      #
      # @param revision_id [String]
      # @return [Boolean] true when the revision was found and applied
      def accept(revision_id) # rubocop:disable Naming/PredicateMethod
        paragraph, node = @nodes[revision_id.to_s]
        return false unless paragraph

        if insertion?(node)
          splice_into_paragraph(paragraph, node, node.runs)
        else
          remove_node(paragraph, node)
        end
        @nodes.delete(revision_id.to_s)
        true
      end

      # Reject one revision: drop inserted content / restore deleted
      # content.
      #
      # @param revision_id [String]
      # @return [Boolean] true when the revision was found and applied
      def reject(revision_id) # rubocop:disable Naming/PredicateMethod
        paragraph, node = @nodes[revision_id.to_s]
        return false unless paragraph

        if insertion?(node)
          remove_node(paragraph, node)
        else
          restored = node.runs.map { |run| restore_run_text(run) }
          splice_into_paragraph(paragraph, node, restored)
        end
        @nodes.delete(revision_id.to_s)
        true
      end

      private

      def insertion?(node)
        node.is_a?(Wordprocessingml::Insertion)
      end

      def facade_revision_for(node)
        Uniword::Revision.new(
          type: insertion?(node) ? :insert : :delete,
          revision_id: node.id.to_s,
          author: node.author,
          date: node.date,
          text: node.text,
        )
      end

      def each_tracked_node(&block)
        containers = [@document.body].compact
        FindReplace::ParagraphWalker.each_paragraph(containers) do |p|
          p.insertions.each { |node| yield(p, node) }
          p.deletions.each { |node| yield(p, node) }
        end
      end

      def splice_into_paragraph(paragraph, node, runs)
        tag = node_tag(node)
        collection = tracked_collection(paragraph, node)
        index = collection.index(node)

        paragraph.runs.concat(runs)
        collection.delete(node)
        replace_order_entry(paragraph, tag, index, runs.size)
      end

      def remove_node(paragraph, node)
        tag = node_tag(node)
        collection = tracked_collection(paragraph, node)
        index = collection.index(node)

        collection.delete(node)
        replace_order_entry(paragraph, tag, index, 0)
      end

      # Convert a deleted run's delText back into live text so a
      # rejected deletion re-enters the document as content.
      def restore_run_text(run)
        deleted = run.del_text
        if deleted
          run.text = [] if run.text.nil?
          run.text << Wordprocessingml::Text.new(content: deleted.content)
          run.del_text = nil
          retag_order_entry(run, "delText", "t")
        end
        run
      end

      def node_tag(node)
        insertion?(node) ? "ins" : "del"
      end

      def tracked_collection(paragraph, node)
        insertion?(node) ? paragraph.insertions : paragraph.deletions
      end

      # Replace the index-th `tag` entry in element_order with `count`
      # run entries (count 0 removes it). Parsed models carry
      # element_order; built models serialize by collection order.
      def replace_order_entry(model, tag, index, count)
        order = Ooxml::ElementOrder.mutable_order(model)
        return unless order
        return unless index

        position = nth_entry_index(order, tag, index)
        return unless position

        entries = Array.new(count) { xml_entry("r") }
        order[position, 1] = entries
      end

      def retag_order_entry(model, old_tag, new_tag)
        order = Ooxml::ElementOrder.mutable_order(model)
        return unless order

        position = nth_entry_index(order, old_tag, 0)
        order[position] = xml_entry(new_tag) if position
      end

      def nth_entry_index(order, tag, nth)
        seen = -1
        order.each_with_index do |entry, i|
          next unless entry.name == tag

          seen += 1
          return i if seen == nth
        end
        nil
      end

      def xml_entry(name)
        Lutaml::Xml::Element.new("Element", name)
      end
    end
  end
end
