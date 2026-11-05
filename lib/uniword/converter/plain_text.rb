# frozen_string_literal: true

module Uniword
  module Converter
    # Plain-text editing round trip for Word documents (issue #80).
    #
    # Bridges Uniword::Wordprocessingml::DocumentRoot to Markdown and
    # AsciiDoc through Coradoc's hub-and-spoke CoreModel:
    #
    #   DocumentRoot -> Coradoc::Docx.parse_to_core -> core
    #     -> (Coradoc::Markdown | Coradoc::AsciiDoc) writer
    #
    #   (Coradoc::Markdown | Coradoc::AsciiDoc) parser -> core
    #     -> Coradoc::Docx.serialize -> DocumentRoot
    #
    # The coradoc gems are OPTIONAL runtime dependencies: they are
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
    #
    # Dropped or degraded (recorded on PlainTextResult, warned about;
    # +strict: true+ raises FidelityError):
    # * headers/footers
    # * section properties
    # * comments
    # * tracked changes (w:ins/w:del)
    # * structured document tags (content survives, wrapper unwrapped)
    # * math (OMML)
    # * images (docx extractor does not carry drawings)
    # * footnotes (coradoc-docx reads the part since 0.1.5 but still
    #   does not carry footnotes into the core model, so they would
    #   vanish silently; the bridge sets it aside and reports them)
    #
    # Never carried by any plain-text format (not detected per document):
    # themes, settings, font table, and other package-level parts.
    #
    # From the plain-text side, links written to DOCX resolve to real
    # External relationships on save. One upstream flattening remains:
    # coradoc-markdown's CoreModel transform emits inline Markdown links
    # as literal text, so from_markdown keeps links as text while
    # from_asciidoc builds real hyperlinks.
    #
    # @example Document to Markdown
    #   md = Uniword::Converter::PlainText.new.to_markdown(document)
    #
    # @example Markdown to a DocumentRoot
    #   doc = Uniword::Converter::PlainText.new.from_markdown(md_text)
    class PlainText
      GEMS_HINT = "coradoc-docx coradoc-markdown coradoc-adoc"

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
        require_gems!("coradoc/docx", "coradoc/markdown")
        drops = detect_dropped_features(document)
        assert_strict!(drops, :markdown) if strict
        core = with_conversion_guards(document, drops) do
          ::Coradoc::Docx.parse_to_core(document)
        end
        build_result(format: :markdown, direction: :docx_to_markdown,
                     core: core, drops: drops, text:
                     ::Coradoc::Markdown.serialize(core))
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
        require_gems!("coradoc/docx", "coradoc/markdown")
        core = ::Coradoc::Markdown.parse_to_core(text)
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
        require_gems!("coradoc/docx", "coradoc/asciidoc")
        drops = detect_dropped_features(document)
        assert_strict!(drops, :asciidoc) if strict
        core = with_conversion_guards(document, drops) do
          ::Coradoc::Docx.parse_to_core(document)
        end
        adoc_model = ::Coradoc::AsciiDoc::Transform::FromCoreModel
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
            ::Coradoc::AsciiDoc::Model::Inline::Bold,
          ) || element.is_a?(::Coradoc::AsciiDoc::Model::Inline::Italic)
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
        require_gems!("coradoc/docx", "coradoc/asciidoc")
        core = ::Coradoc::AsciiDoc.parse_to_core(text)
        finish_from_core(format: :asciidoc,
                         direction: :asciidoc_to_docx,
                         core: core, strict: strict)
      end

      private

      # Lazily load the coradoc gems; raise a DependencyError with an
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
        features << "footnotes" if user_footnotes?(document)
        features
      end

      def assert_strict!(drops, format)
        return if drops.empty?

        raise FidelityError.new(format, drops)
      end

      # Temporarily set aside content the writers would silently drop
      # (footnotes never reach the coradoc core model) and rewrite
      # hyperlink rIds to their target URLs so the writers emit real
      # links; every mutation is restored after the conversion.
      def with_conversion_guards(document, drops)
        stash = {}
        if drops.include?("footnotes")
          stash[:footnotes] = document.footnotes
          document.footnotes = nil
        end
        rewrites = resolve_link_targets(document)
        begin
          yield
        ensure
          restore_link_targets(rewrites)
          document.footnotes = stash[:footnotes] if stash.key?(:footnotes)
        end
      end

      # Rewrite w:hyperlink r:id attributes to their relationship
      # targets so coradoc's writers emit real URLs instead of "rId1".
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
        document = ::Coradoc::Docx.serialize(core)
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
            when ::Coradoc::CoreModel::StructuralElement
              counts[:headings] += 1 if heading?(node)
            when ::Coradoc::CoreModel::Block
              counts[:paragraphs] += 1
            when ::Coradoc::CoreModel::ListBlock
              counts[:lists] += 1
            when ::Coradoc::CoreModel::Table
              counts[:tables] += 1
            when ::Coradoc::CoreModel::InlineElement
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
        when ::Coradoc::CoreModel::StructuralElement
          Array(node.children)
        when ::Coradoc::CoreModel::Block
          content = node.renderable_content
          content.is_a?(Array) ? content.grep(::Coradoc::CoreModel::Base) : []
        when ::Coradoc::CoreModel::ListBlock
          Array(node.items)
        when ::Coradoc::CoreModel::Table
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

      def user_footnotes?(document)
        footnotes = document.footnotes
        unless footnotes.is_a?(Uniword::Wordprocessingml::Footnotes)
          return false
        end

        footnotes.footnote_entries.any? do |entry|
          entry.type != "separator" && entry.type != "continuationSeparator"
        end
      end
    end
  end
end
