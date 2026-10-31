# frozen_string_literal: true

module Uniword
  module Template
    # Fills document placeholders (mail merge) from a data hash.
    #
    # Three placeholder sources are recognised, in precedence order:
    #
    # 1. Content controls — a w:sdt whose sdtPr alias or tag names a
    #    variable has its content replaced with the value (the first
    #    run's properties are kept, extra runs are dropped).
    # 2. Mail merge fields — a w:fldSimple whose instr is
    #    `MERGEFIELD name` (first token after MERGEFIELD, quoted names
    #    allowed) has its run content replaced with the value.
    # 3. `{{var}}` text placeholders inside run text (w:t).
    #
    # Data keys may be strings or symbols; nested hashes are flattened
    # to dotted paths ({"client" => {"name" => "X"}} fills
    # {{client.name}}).
    #
    # V1 limitations:
    # - A `{{var}}` placeholder must be fully contained in a single
    #   run's text; cross-run placeholders are not stitched.
    # - Only the main document body is scanned (paragraphs, tables,
    #   block/inline content controls, hyperlink runs); headers,
    #   footers, footnotes, and complex (fldChar) fields are not.
    # - A filled content control's value is inserted verbatim and is
    #   not rescanned for further placeholders.
    #
    # @example
    #   result = Filler.new(document).fill(
    #     { "client" => { "name" => "X" }, "total" => 42 }
    #   )
    #   result.total_filled  # => 2
    #   result.missing       # => ["editor"]
    class Filler
      PLACEHOLDER_PATTERN = /\{\{\s*([^{}]+?)\s*\}\}/
      MERGEFIELD_PATTERN = /\A\s*MERGEFIELD\s+(?:"([^"]*)"|(\S+))/i

      # @param document [Wordprocessingml::DocumentRoot] document to fill
      def initialize(document)
        @document = document
      end

      # Fill all recognised placeholders in the document body.
      #
      # @param data [Hash] values keyed by variable name (nested hashes
      #   become dotted paths); missing keys leave their placeholders
      #   untouched
      # @param strict [Boolean] when true, raise MissingVariablesError
      #   if any placeholder names a variable absent from +data+
      # @return [FillResult] filled counts per source kind and missing names
      # @raise [MissingVariablesError] when strict and variables are missing
      def fill(data, strict: false)
        @variables = flatten_data(data)
        @result = FillResult.new

        fill_container(@document.body) if @document.body

        if strict && @result.missing.any?
          raise MissingVariablesError, @result.missing
        end

        @result
      end

      private

      # Recursively fill one block-level container. Dispatch is
      # explicit per container class (mirrors FindReplace::ParagraphWalker):
      # Body maps structured_document_tags, TableCell maps no SDTs, and
      # SDT Content maps sdts plus direct runs.
      def fill_container(container)
        case container
        when Wordprocessingml::Body
          fill_body(container)
        when Wordprocessingml::TableCell
          fill_cell(container)
        when Wordprocessingml::StructuredDocumentTag::Content
          fill_sdt_content(container)
        end
      end

      def fill_body(body)
        Array(body.structured_document_tags).each { |sdt| fill_sdt(sdt) }
        fill_paragraphs(body.paragraphs)
        fill_tables(body.tables)
      end

      def fill_cell(cell)
        fill_paragraphs(cell.paragraphs)
        fill_tables(cell.tables)
      end

      def fill_sdt_content(content)
        Array(content.sdts).each { |sdt| fill_sdt(sdt) }
        fill_paragraphs(content.paragraphs)
        fill_tables(content.tables)
        fill_run_placeholders(Array(content.runs))
      end

      def fill_tables(tables)
        Array(tables).each do |table|
          Array(table.rows).each do |row|
            Array(row.cells).each { |cell| fill_container(cell) if cell }
          end
        end
      end

      def fill_paragraphs(paragraphs)
        Array(paragraphs).each { |para| fill_paragraph(para) }
      end

      def fill_paragraph(para)
        fill_run_placeholders(Array(para.runs))
        Array(para.sdts).each { |sdt| fill_sdt(sdt) }
        Array(para.simple_fields).each { |field| fill_field(field) }
        fill_hyperlink_placeholders(para)
      end

      def fill_hyperlink_placeholders(para)
        Array(para.hyperlinks).each do |link|
          fill_run_placeholders(Array(link.runs))
        end
      end

      # Content control: alias wins over tag as the variable name.
      def fill_sdt(sdt)
        name = sdt_variable_name(sdt)

        if name
          if @variables.key?(name)
            write_value(sdt_run_slots(sdt), stringify(@variables[name]),
                        sdt_append_target(sdt))
            @result.add(:sdt)
            return
          end

          @result.record_missing(name)
        end

        fill_container(sdt.content) if sdt.content
      end

      # Simple field: parse the MERGEFIELD instruction, fill when known.
      def fill_field(field)
        name = parse_mergefield(field.instr)
        return unless name

        if @variables.key?(name)
          slots = Array(field.runs).map { |run| [field.runs, run] }
          write_value(slots, stringify(@variables[name]), field.runs)
          @result.add(:mergefield)
        else
          @result.record_missing(name)
        end
      end

      # {{var}} substitution inside each run's text elements.
      def fill_run_placeholders(runs)
        runs.each do |run|
          Array(run.text).each { |text_el| fill_text_object(text_el) }
        end
      end

      def fill_text_object(text_el)
        content = text_el.content.to_s
        replaced = replace_placeholders(content)
        return if replaced == content

        text_el.content = replaced
        preserve = Wordprocessingml::Text.preserve_whitespace?(replaced)
        text_el.xml_space = preserve ? "preserve" : nil
      end

      # Substitute every {{var}} occurrence, recording missing names
      # and leaving those placeholders verbatim.
      def replace_placeholders(content)
        content.gsub(PLACEHOLDER_PATTERN) do
          match = Regexp.last_match
          name = match[1]

          if @variables.key?(name)
            @result.add(:text)
            stringify(@variables[name])
          else
            @result.record_missing(name)
            match[0]
          end
        end
      end

      # Run slots ([collection, run] pairs) inside a content control,
      # in document order: direct content runs, then paragraph runs
      # (including runs inside paragraph hyperlinks).
      def sdt_run_slots(sdt)
        content = sdt.content
        return [] if content.nil?

        slots = run_slots(content.runs)
        Array(content.paragraphs).each do |para|
          slots.concat(para_run_slots(para))
        end
        slots
      end

      def run_slots(runs)
        Array(runs).map { |run| [runs, run] }
      end

      def para_run_slots(para)
        slots = run_slots(para.runs)
        Array(para.hyperlinks).each do |link|
          slots.concat(run_slots(link.runs))
        end
        slots
      end

      # Where a fresh run is appended when a content control has no
      # runs at all: the first content paragraph, else the content's
      # direct run collection.
      def sdt_append_target(sdt)
        content = sdt.content
        return nil if content.nil?

        first_para = Array(content.paragraphs).first
        first_para ? first_para.runs : content.runs
      end

      # Write a value into run slots: keep the first run (and its
      # properties) with the new text, drop the remaining runs. When
      # there are no runs, append a fresh run unless the value is
      # empty.
      def write_value(slots, value, append_target)
        if slots.empty?
          return if value.empty? || append_target.nil?

          append_target << Wordprocessingml::Run.new(text: [make_text(value)])
          return
        end

        _owner, first = slots.first
        first.text = [make_text(value)]
        slots.drop(1).each { |owner, run| owner.delete(run) }
      end

      def sdt_variable_name(sdt)
        props = sdt.properties
        return nil unless props

        alias_name = props.alias_name&.value.to_s
        return alias_name unless alias_name.empty?

        tag = props.tag&.value.to_s
        tag.empty? ? nil : tag
      end

      def parse_mergefield(instr)
        match = instr.to_s.match(MERGEFIELD_PATTERN)
        return nil unless match

        match[1] || match[2]
      end

      # Text object following the run text convention: xml:space
      # preserved when the value has leading/trailing spaces, tabs, or
      # newlines (mirrors Run's own text handling).
      def make_text(string)
        text_el = Wordprocessingml::Text.new(content: string)
        text_el.xml_space = "preserve" if Wordprocessingml::Text.preserve_whitespace?(string)
        text_el
      end

      def stringify(value)
        value.nil? ? "" : value.to_s
      end

      # Flatten nested hashes into dotted-path string keys.
      def flatten_data(hash, prefix = nil)
        hash.each_with_object({}) do |(key, value), out|
          name = prefix ? "#{prefix}.#{key}" : key.to_s

          if value.is_a?(Hash)
            out.update(flatten_data(value, name))
          else
            out[name] = value
          end
        end
      end
    end
  end
end
