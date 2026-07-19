# frozen_string_literal: true

module Uniword
  module Docx
    # A package part no Ooxml::PartDefinition models, carried verbatim
    # for round-trip fidelity (e.g. docProps/meta.xml, glossary
    # documents, VBA projects, unmodelled .rels sidecars).
    #
    # Unlike document-scoped parts (charts, images, embeddings), a raw
    # part keeps its full package-relative +path+ — raw parts live
    # anywhere in the package, not only under word/. Content is the
    # exact source byte stream (binary-safe; never parsed or
    # re-encoded), plus the content type the source
    # [Content_Types].xml declared for it (Override first, then
    # Default by extension; nil when the source declared neither).
    #
    # The relationship referencing the part (when one exists in a
    # modelled .rels part) is recorded as +r_id+/+rel_type+ metadata
    # for introspection parity with other part kinds; emission never
    # uses it — relationships re-serialize from the loaded rels
    # models, so the source rel survives untouched.
    #
    # Raw parts are a fallback: PartLoader claims every registry-known
    # path first and RawPartLoader carries only the remainder, so a
    # part is never emitted twice.
    #
    # @example
    #   part = RawPart.new(
    #     path: "docProps/meta.xml",
    #     content: bytes,
    #     content_type: "application/xml",
    #   )
    #   part.package_paths # => ["docProps/meta.xml"]
    class RawPart < Part
      # @return [String, nil] package-relative path, verbatim
      attr_writer :path

      # @param path [String, nil] package-relative path
      #   (e.g. "docProps/meta.xml")
      # @param content [String, nil] raw part bytes (binary-safe)
      # @param content_type [String, nil] content type declared by the
      #   source [Content_Types].xml
      # @param r_id [String, nil] id of the relationship referencing
      #   this part (metadata only)
      # @param rel_type [String, nil] type of the relationship
      #   referencing this part (metadata only)
      def initialize(path: nil, content: nil, content_type: nil,
                     r_id: nil, rel_type: nil)
        super(content: content, content_type: content_type,
              r_id: r_id, rel_type: rel_type)
        @path = path
      end

      # Wrap a raw-hash entry ({ path:, content:, content_type: })
      # into a RawPart. Used by PartCollection to normalize hash
      # assignments.
      #
      # @param hash [Hash] raw hash entry
      # @return [RawPart]
      def self.from_hash(hash)
        new(path: hash[:path], content: hash[:content],
            content_type: hash[:content_type],
            r_id: hash[:r_id], rel_type: hash[:rel_type])
      end

      # Package-relative path of the emitted part, carried verbatim
      # (overrides Part's word/-prefixed target derivation).
      #
      # @return [String, nil] e.g. "word/glossary/document.xml"
      def path
        @path
      end
    end
  end
end
