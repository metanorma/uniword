# frozen_string_literal: true

module Uniword
  module Converter
    # Plain-text editing round trip for Word documents (issue #80).
    #
    # Bridges Uniword::Wordprocessingml::DocumentRoot to Markdown and
    # AsciiDoc through Ceradoc's hub-and-spoke CoreModel:
    #
    #   DocumentRoot -> Ceradoc::Docx.parse_to_core -> core
    #     -> (Ceradoc::Markdown | Ceradoc::AsciiDoc) writer
    #
    #   (Ceradoc::Markdown | Ceradoc::AsciiDoc) parser -> core
    #     -> Ceradoc::Docx.serialize -> DocumentRoot
    #
    # The ceradoc gems are OPTIONAL runtime dependencies: they are
    # required lazily inside the conversion methods, never at file
    # load. When missing, a DependencyError with an install hint is
    # raised.
    #
    # == Fidelity boundary
    #
    # Supported (round-tripped through the CoreModel):
    # * headings h1-h6, paragraphs
    # * bold / italic / underline / strikethrough runs
    # * bulleted and numbered lists
    # * tables with a header row
    # * links (bridge resolves relationship ids to target URLs)
    # * bookmarks (heading/paragraph anchor id propagation)
    # * footnotes (ceradoc-docx 0.1.6 carries them into the core
    #   model; to md/adoc emits GFM [^id] + definitions)
    #
    # Dropped or degraded (recorded on PlainTextResult, warned about;
    # +strict: true+ raises FidelityError):
    # * headers/footers
    # * section properties
    # * comments
    # * tracked changes (w:ins/w:del)
    # * structured document tags (content survives, wrapper unwrapped)
    # * math (OMML)
    # * images (docx extractor does not carry drawings; ceradoc#322)
    #
    # Never carried by any plain-text format (not detected per document):
    # themes, settings, font table, and other package-level parts.
    #
    # From the plain-text side, links written to DOCX resolve to real
    # External relationships on save, and from_markdown builds real
    # hyperlinks from inline Markdown links (ceradoc-markdown fixed the
    # literal-text flattening, ceradoc#320). Upstream flattening that
    # remains: from_markdown footnote REFERENCES stay literal text
    # (definitions do convert, ceradoc#320).
    #
    # @example Document to Markdown
    #   md = Uniword::Converter::PlainText.new.to_markdown(document)
    #
    # @example Markdown to a DocumentRoot
    #   doc = Uniword::Converter::PlainText.new.from_markdown(md_text)
    class PlainText
      GEMS_HINT = "ceradoc-docx ceradoc-markdown ceradoc-adoc"

      # Convert a document to Markdown.
      #
      # @param document [Wordprocessingml::DocumentRoot] source document
      # @param strict [Boolean] raise when features would be dropped
      # @return [String] the Markdown text
      # @raise [FidelityError] in strict mode with dropped features
      def to_markdown(document, strict: false)
        result = to_markdown_result(document, strict: strict)
        warn_dropped_features(result)
        result.text
      end

      # Convert a document to Markdown with a full result record.
      #
      # @param document [Wordprocessingml::DocumentRoot] source document
      # @param strict [Boolean] raise when features would be dropped
      # @return [PlainTextResult]
      # @raise [FidelityError] in strict mode with dropped features
      def to_markdown_result(document, strict: false)
        require_gems!("ceradoc/docx", "ceradoc/markdown")
        drops = detect_dropped_features(document)
        assert_strict!(drops, :markdown) if strict
        core = with_conversion_guards(document, drops) do
          ::Ceradoc::Docx.parse_to_core(document)
        end
        build_result(format: :markdown, direction: :docx_to_markdown,
                     core: core, drops: drops, text:
                     ::Ceradoc::Markdown.serialize(core))
      end

      # Parse Markdown into a document model.
      #
      # @param text [String] Markdown source
      # @param strict [Boolean] raise when features would be dropped
      # @return [Wordprocessingml::DocumentRoot]
      def from_markdown(text, strict: false)
        result = from_markdown_result(text, strict: strict)
        warn_dropped_features(result)
        result.document
      end

      # Parse Markdown into a document model with a full result record.
      #
      # @param text [String] Markdown source
      # @param strict [Boolean] raise when features would be dropped
      # @return [PlainTextResult]
      def from_markdown_result(text, strict: false)
        require_gems!("ceradoc/docx", "ceradoc/markdown")
        core = ::Ceradoc::Markdown.parse_to_core(text)
        finish_from_core(format: :markdown,
                         direction: :markdown_to_docx,
                         core: core, strict: strict)
      end

      # Convert a document to AsciiDoc.
      #
      # @param document [Wordprocessingml::DocumentRoot] source document
      # @param strict [Boolean] raise when features would be dropped
      # @return [String] the AsciiDoc text
      # @raise [FidelityError] in strict mode with dropped features
      def to_asciidoc(document, strict: false)
        result = to_asciidoc_result(document, strict: strict)
        warn_dropped_features(result)
        result.text
      end

      # Convert a document to AsciiDoc with a full result record.
      #
      # @param document [Wordprocessingml::DocumentRoot] source document
      # @param strict [Boolean] raise when features would be dropped
      # @return [PlainTextResult]
      # @raise [FidelityError] in strict mode with dropped features
      def to_asciidoc_result(document, strict: false)
        require_gems!("ceradoc/docx", "ceradoc/asciidoc")
        drops = detect_dropped_features(document)
        assert_strict!(drops, :asciidoc) if strict
        core = with_conversion_guards(document, drops) do
          ::Ceradoc::Docx.parse_to_core(document)
        end
        adoc_model = ::Ceradoc::AsciiDoc::Transform::FromCoreModel
          .transform(core)
        normalize_emphasis_constraint!(adoc_model)
        build_result(format: :asciidoc, direction: :docx_to_asciidoc,
                     core: core, drops: drops, text: adoc_model.to_adoc)
      end

      # CoreModel carries no emphasis constraint, and the framework's
      # flank guess can downgrade boundary-flanked runs to the
      # constrained spelling, which does not reparse mid-word. The
      # DOCX contract emits the unconstrained forms (`**bold**`,
      # `__italic__`) — they parse unconditionally — so the
      # converter restores the emphasis models' own unconstrained
      # default after the transform.
      def normalize_emphasis_constraint!(model)
        model.visit do |element, _phase|
          element.unconstrained = true if element.is_a?(
            ::Ceradoc::AsciiDoc::Model::Inline::Bold,
          ) || element.is_a?(::Ceradoc::AsciiDoc::Model::Inline::Italic)
          element
        end
        model
      end

      # Parse AsciiDoc into a document model.
      #
      # @param text [String] AsciiDoc source
      # @param strict [Boolean] raise when features would be dropped
      # @return [Wordprocessingml::DocumentRoot]
      def from_asciidoc(text, strict: false)
        result = from_asciidoc_result(text, strict: strict)
        warn_dropped_features(result)
        result.document
      end

      # Parse AsciiDoc into a document model with a full result record.
      #
      # @param text [String] AsciiDoc source
      # @param strict [Boolean] raise when features would be dropped
      # @return [PlainTextResult]
      def from_asciidoc_result(text, strict: false)
        require_gems!("ceradoc/docx", "ceradoc/asciidoc")
        core = ::Ceradoc::AsciiDoc.parse_to_core(text)
        finish_from_core(format: :asciidoc,
                         direction: :asciidoc_to_docx,
                         core: core, strict: strict)
      end

      private

      # Lazily load the ceradoc gems; raise a DependencyError with an
      # install hint when any is missing.
      def require_gems!(*libs)
        libs.each { |lib| require lib }
      rescue LoadError
        raise DependencyError.new(GEMS_HINT, "plain-text conversion")
      end

      # Detect features present in the source document that the
      # plain-text target drops or degrades. Order is presentation
      # order; each check maps to a documented fidelity boundary.
      def detect_dropped_features(document)
        features = []
        features << "headers/footers" unless document.header_footer_parts.empty?
        unless document.body&.section_properties.nil?
          features << "section properties"
        end
        features << "comments" if comments_present?(document)
        if any_paragraph?(document) { |p| tracked?(p) }
          features << "tracked changes"
        end
        if any_paragraph?(document) { |p| sdt?(p) } ||
            Array(document.body&.structured_document_tags).any?
          features << "structured document tags (unwrapped)"
        end
        features << "math (OMML)" if any_paragraph?(document) { |p| math?(p) }
        features << "images" if any_paragraph?(document) { |p| drawing?(p) }
        features
      end

      def assert_strict!(drops, format)
        return if drops.empty?

        raise FidelityError.new(format, drops)
      end

      # Rewrite hyperlink rIds to their target URLs so ceradoc's
      # writers emit real links; every mutation is restored after the
      # conversion.
      def with_conversion_guards(document, _drops)
        rewrites = resolve_link_targets(document)
        yield.tap { restore_link_targets(rewrites) }
      end

      # Rewrite w:hyperlink r:id attributes to their relationship
      # targets so ceradoc's writers emit real URLs instead of "rId1".
      # Relationships live in document.xml.rels on loaded documents
      # and in the IdAllocator on builder-built ones; both sources are
      # consulted. Returns the rewrite log for restoration.
      def resolve_link_targets(document)
        rewrites = []
        rels = relationship_lookup(document)
        return rewrites if rels.empty?

        each_document_hyperlink(document) do |hyperlink|
          rel = rels[hyperlink.id.to_s]
          next unless rel && rel[:target] &&
            rel[:target_mode] == "External"

          rewrites << [hyperlink, hyperlink.id]
          hyperlink.id = rel[:target]
        end
        rewrites
      end

      # rId => { target:, target_mode: } across both relationship
      # sources; allocator entries never override explicit rels.
      def relationship_lookup(document)
        lookup = {}
        Array(document.document_rels&.relationships).each do |rel|
          lookup[rel.id.to_s] =
            { target: rel.target, target_mode: rel.target_mode }
        end
        Array(document.allocator&.all_rels).each do |entry|
          lookup[entry[:id].to_s] ||=
            { target: entry[:target], target_mode: entry[:target_mode] }
        end
        lookup
      end

      def restore_link_targets(rewrites)
        rewrites.each { |hyperlink, original| hyperlink.id = original }
      end

      def build_result(format:, direction:, core:, drops:, text: nil,
                       document: nil)
        PlainTextResult.new(
          format: format,
          direction: direction,
          block_counts: count_blocks(core),
          dropped_features: drops,
          text: text,
          document: document,
        )
      end

      # Serialize the CoreModel into a DocumentRoot and wrap both in a
      # result (from_* direction).
      def finish_from_core(format:, direction:, core:, strict:)
        document = ::Ceradoc::Docx.serialize(core)
        build_result(format: format, direction: direction, core: core,
                     drops: [], document: document).tap do |result|
          assert_strict!(result.dropped_features, format) if strict
        end
      end

      def warn_dropped_features(result)
        return if result.clean?

        result.dropped_features.each do |feature|
          Uniword.logger.warn(
            "plain-text conversion (#{result.direction}) dropped: #{feature}",
          )
        end
      end

      # ---- CoreModel block counting ---------------------------------

      def count_blocks(core)
        counts = Hash.new(0)
        Array(core).each do |root|
          walk_core(root, skip_self: true) do |node|
            case node
            when ::Ceradoc::CoreModel::StructuralElement
              counts[:headings] += 1 if heading?(node)
            when ::Ceradoc::CoreModel::Block
              counts[:paragraphs] += 1
            when ::Ceradoc::CoreModel::ListBlock
              counts[:lists] += 1
            when ::Ceradoc::CoreModel::Table
              counts[:tables] += 1
            when ::Ceradoc::CoreModel::InlineElement
              counts[:links] += 1 if link?(node)
            end
          end
        end
        counts
      end

      def heading?(element)
        element.title && element.heading_level.to_i >= 1
      end

      def link?(inline)
        inline.resolve_format_type == "link"
      end

      def walk_core(node, skip_self: false, &block)
        yield node unless skip_self
        children_of(node).each { |child| walk_core(child, &block) }
      end

      def children_of(node)
        case node
        when ::Ceradoc::CoreModel::StructuralElement
          Array(node.children)
        when ::Ceradoc::CoreModel::Block
          content = node.renderable_content
          content.is_a?(Array) ? content.grep(::Ceradoc::CoreModel::Base) : []
        when ::Ceradoc::CoreModel::ListBlock
          Array(node.items)
        when ::Ceradoc::CoreModel::Table
          Array(node.rows).flat_map { |row| Array(row.cells) }
        else
          []
        end
      end

      # ---- DocumentRoot content traversal ---------------------------

      def any_paragraph?(document, &block)
        each_document_paragraph(document).any?(&block)
      end

      def each_document_paragraph(document, &block)
        return enum_for(:each_document_paragraph, document) unless block

        body = document.body
        return unless body

        Array(body.paragraphs).each(&block)
        Array(body.tables).each do |table|
          each_table_paragraph(table, &block)
        end
      end

      def each_table_paragraph(table, &block)
        Array(table.rows).each do |row|
          Array(row.cells).each do |cell|
            Array(cell.paragraphs).each(&block)
            Array(cell.tables).each do |nested|
              each_table_paragraph(nested, &block)
            end
          end
        end
      end

      def each_document_hyperlink(document, &block)
        each_document_paragraph(document) do |paragraph|
          Array(paragraph.hyperlinks).each(&block)
        end
      end

      # ---- Feature predicates ---------------------------------------

      def tracked?(paragraph)
        Array(paragraph.insertions).any? ||
          Array(paragraph.deletions).any?
      end

      def sdt?(paragraph)
        Array(paragraph.sdts).any?
      end

      def math?(paragraph)
        Array(paragraph.o_maths).any? || Array(paragraph.o_math_paras).any?
      end

      def drawing?(paragraph)
        paragraph.runs.any? { |run| Array(run.drawings).any? }
      end

      def comments_present?(document)
        # nil (no comments part) and unexpected forms count as absent;
        # the legacy Array form is tolerated.
        case (comments = document.comments)
        when Uniword::CommentsPart then !comments.empty?
        when Array then comments.any?
        else false
        end
      end
    end
  end
end
