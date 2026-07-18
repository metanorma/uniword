# frozen_string_literal: true

require "spec_helper"
require "nokogiri"

# Spec-only lint namespace (not part of the shipped gem).
module Lint
  # Static + runtime analysis of every Lutaml::Model::Serializable model
  # defined under lib/. Backs spec/lint/model_definitions_spec.rb.
  #
  # Five invariants are checked (see the spec below):
  #
  # 1. Pattern 0 — in every model class, all `attribute` declarations
  #    precede the class's `xml do` block (attributes declared afterwards
  #    are silently ignored by lutaml-model, producing empty XML output).
  # 2. Every `map_attribute`/`map_element`/`map_content` `to:` target
  #    resolves to a declared attribute of the class.
  # 3. Every declared attribute is mapped in the `xml do` block (an
  #    explicit, commented whitelist covers intentional transient
  #    attributes).
  # 4. Every `xml do` block declares a namespace.
  # 5. Fresh-instance `.to_xml` smoke: non-empty, well-formed XML for
  #    every class constructible without required arguments.
  module ModelDefinitions
    LIB_ROOT = File.expand_path("../../lib", __dir__)

    # Files that cannot be eager-loaded at all (class body raises during
    # definition). Pre-existing broken dead code; classes they (partially)
    # define are excluded from the runtime checks. Keyed by repo-relative
    # path; value is the exception class raised at load time.
    KNOWN_LOAD_FAILURES = {
      # Generated code declares `attribute true, :string` (bare `true` as
      # the attribute name) — invalid lutaml-model API. All five files.
      "lib/uniword/office/callout.rb" => "NoMethodError",
      "lib/uniword/office/extrusion.rb" => "NoMethodError",
      "lib/uniword/office/metal.rb" => "NoMethodError",
      "lib/uniword/office/skew.rb" => "NoMethodError",
      "lib/uniword/vml_office/vml_office_fill.rb" => "NoMethodError",
      # References undefined constant Ooxml::Namespaces::Word2010Ext.
      "lib/uniword/word2010_ext/wrap.rb" => "NameError",
      # Declares `namespace:` on map_attribute, which lutaml-model rejects
      # (namespaces belong on the model class, not on attribute mappings).
      "lib/uniword/wordprocessingml/num.rb" =>
        "Lutaml::Model::IncorrectMappingArgumentsError",
    }.freeze

    # Declared attributes intentionally not mapped in the class's `xml do`
    # block (transient/convenience state). Exact match is enforced: adding
    # an unmapped attribute or mapping a whitelisted one both fail the
    # check, keeping this list honest. Keyed by class name.
    UNMAPPED_ATTRIBUTES = {
      # Element#id is a transient common ID inherited from the abstract
      # base; w:comment's w:id maps to :comment_id instead.
      "Uniword::Comment" => %i[id],
      # Same inherited Element#id; w:commentRangeStart's w:id maps to
      # :comment_id instead.
      "Uniword::CommentRange" => %i[id],
      # :panose is emitted only for a:latin (mapped on LatinFont); the
      # ea/cs variants intentionally carry typeface only.
      "Uniword::Drawingml::CsFont" => %i[panose],
      "Uniword::Drawingml::EaFont" => %i[panose],
      # Metadata facade: the drawing XML is built by the images module;
      # these attributes are image metadata, not direct XML mappings
      # (:id is the inherited transient Element#id).
      "Uniword::Image" => %i[
        id relationship_id width height alt_text title filename inline
        horizontal_alignment vertical_alignment text_wrapping
      ],
      # Reserved attribute; PreviewPicture is not part of the app.xml
      # mapping.
      "Uniword::Ooxml::AppProperties" => %i[preview_picture],
      # xsi:type="dcterms:W3CDTF" marker class, not referenced by any
      # mapping; :value is intentionally unmapped.
      "Uniword::Ooxml::Types::DctermsW3cdtfType" => %i[value],
      # Documented in source as transient: sibling-run position used by
      # the MHTML renderer.
      "Uniword::Wordprocessingml::Hyperlink" => %i[run_position],
      # Documented in source as mapping to child elements (w:name /
      # w:styleLink); that child-element mapping is not implemented
      # (pre-existing gap).
      "Uniword::Wordprocessingml::NumberingDefinition" => %i[
        name style_link
      ],
      # Flat convenience API for builders (documented in source); XML
      # serialization goes through the spacing/indentation/shading/
      # numbering wrapper objects.
      "Uniword::Wordprocessingml::ParagraphProperties" => %i[
        spacing_before spacing_after line_spacing line_rule indent_left
        indent_right indent_first_line num_id ilvl shading_fill
        shading_color shading_type
      ],
      # w:outlineLvl is a paragraph-level element in OOXML; kept on
      # RunProperties for StyleSet convenience, intentionally unmapped.
      "Uniword::Wordprocessingml::RunProperties" => %i[outline_level],
      # Convenience flat attributes for API access (documented in
      # source); cell XML uses the properties wrapper.
      "Uniword::Wordprocessingml::TableCell" => %i[
        column_span row_span vertical_alignment width background_color
      ],
      # Convenience width attribute (documented in source); XML uses the
      # :cell_width wrapper.
      "Uniword::Wordprocessingml::TableCellProperties" => %i[width],
      # Flat convenience attributes (documented in source); XML
      # serialization uses the wrapper objects (table_indent,
      # table_borders, ...).
      "Uniword::Wordprocessingml::TableProperties" => %i[
        indent borders allow_break
        border_top_style border_top_size border_top_color
        border_bottom_style border_bottom_size border_bottom_color
        border_left_style border_left_size border_left_color
        border_right_style border_right_size border_right_color
        border_inside_h_style border_inside_h_size border_inside_h_color
        border_inside_v_style border_inside_v_size border_inside_v_color
      ],
    }.freeze

    # Classes that fail the fresh-instance to_xml smoke check for a known,
    # pre-existing reason. Value is the exception class raised.
    KNOWN_SMOKE_FAILURES = {
      # `attribute :grp_sp, :self` — the :self type is not supported by
      # the uniword type register, so .new raises before to_xml.
      "Uniword::Drawingml::GvmlGroupShape" =>
        "Lutaml::Model::UnknownTypeError",
    }.freeze

    # One class definition found in one source file. A class defined in
    # several files (reopened) yields one Entry per file.
    class Entry
      attr_reader :fqcn, :file, :attribute_lines, :xml_do_line

      def initialize(fqcn:, file:)
        @fqcn = fqcn
        @file = file
        @attribute_lines = []
        @xml_do_line = nil
      end

      def record_attribute(lineno)
        @attribute_lines << lineno
      end

      def record_xml_do(lineno)
        @xml_do_line = lineno unless xml_do?
      end

      def xml_do?
        !@xml_do_line.nil?
      end

      # Pattern 0: attribute declaration lines after the xml do block.
      #
      # @return [Array<Integer>] offending line numbers
      def late_attribute_lines
        return [] unless xml_do?

        @attribute_lines.select { |lineno| lineno > @xml_do_line }
      end
    end

    # Line-oriented scanner extracting class definitions, `attribute`
    # declarations, and `xml do` blocks from one source file. Relies on
    # the repo's RuboCop-enforced 2-space indentation: a class body's
    # direct statements sit exactly one level deeper than the `class`
    # keyword, and the class-closing `end` sits at the same level.
    class SourceScanner
      SCOPE_RE = %r{^(\s*)(?:module|class)\s+([A-Z]\w*(?:::[A-Z]\w*)*)}
      END_RE = /^(\s*)end\b/
      ONE_LINE_RE = /;\s*end\b/

      def initialize(path)
        @path = path
        @entries = {}
        @scope_stack = []
      end

      # @return [Array<Entry>] class entries found in the file
      def scan
        sanitize(File.readlines(@path)).each_with_index do |line, idx|
          lineno = idx + 1
          if (match = line.match(SCOPE_RE))
            push_scope(match, line)
          elsif (match = line.match(END_RE))
            pop_scopes(match[1].length)
          else
            record_statement(line, lineno)
          end
        end
        @entries.values
      end

      private

      def push_scope(match, line)
        name = match[2]
        is_class = line.match?(/^\s*class\s/)
        return if line.match?(ONE_LINE_RE)

        fqcn = (@scope_stack.map { |scope| scope[:name] } + [name]).join("::")
        @scope_stack << { name: name, indent: match[1].length, class: is_class }
        @entries[fqcn] = Entry.new(fqcn: fqcn, file: @path) if is_class
      end

      def pop_scopes(indent)
        @scope_stack.pop while @scope_stack.any? &&
            @scope_stack.last[:indent] >= indent
      end

      def record_statement(line, lineno)
        inner = @scope_stack.reverse.find { |scope| scope[:class] }
        return unless inner

        entry = @entries[@scope_stack.map { |scope| scope[:name] }.join("::")]
        return unless entry

        record_declaration(line, lineno, inner[:indent] + 2, entry)
      end

      def record_declaration(line, lineno, body_indent, entry)
        if line.match?(/^\s{#{body_indent}}attribute\s/)
          entry.record_attribute(lineno)
        elsif line.match?(/^\s{#{body_indent}}xml\s+do\b/)
          entry.record_xml_do(lineno)
        end
      end

      # Drop heredoc bodies and =begin/=end blocks so string content that
      # looks like code cannot fool the line scanner.
      def sanitize(lines)
        strip_heredocs(strip_block_comments(lines))
      end

      def strip_block_comments(lines)
        in_comment = false
        lines.reject do |line|
          if in_comment
            in_comment = false if line.match?(/^=end\b/)
            true
          else
            in_comment = line.match?(/^=begin\b/)
          end
        end
      end

      def strip_heredocs(lines)
        terminator = nil
        lines.reject do |line|
          if terminator
            terminator = nil if line.match?(/^\s*#{terminator}\b/)
            true
          else
            terminator = heredoc_marker(line)
            false
          end
        end
      end

      def heredoc_marker(line)
        match = line.match(/<<[-~]?["']?(\w+)["']?/)
        match && match[1]
      end
    end

    # Outcome of analyzing all model definitions under lib/.
    class Report
      attr_reader :load_failures, :pattern0_violations, :undeclared_targets,
                  :unmapped_attributes, :missing_namespaces, :smoke_failures

      def initialize
        @load_failures = {}
        @pattern0_violations = []
        @undeclared_targets = []
        @unmapped_attributes = {}
        @missing_namespaces = []
        @smoke_failures = {}
      end
    end

    module_function

    # @return [Report] memoized analysis of every model under lib/
    def analysis
      @analysis ||= analyze
    end

    # Expected shape of Report#unmapped_attributes: class name =>
    # alphabetically sorted attribute list, derived from the whitelist.
    def expected_unmapped
      UNMAPPED_ATTRIBUTES.transform_values { |attrs| attrs.sort_by(&:to_s) }
    end

    def analyze
      report = Report.new
      files = eager_load_lib(report)
      entries = files.flat_map { |file| SourceScanner.new(file).scan }
      check_pattern0(entries, report)
      models = resolve_models(entries)
      check_mappings(models, report)
      run_smoke(models, report)
      report
    end

    # Require every lib file so all model classes are defined, collecting
    # load failures keyed by repo-relative path.
    def eager_load_lib(report)
      # Sort is load-bearing, not redundant: Dir[] order is not sorted on
      # all platforms, and some files depend on load order.
      # rubocop:disable Lint/RedundantDirGlobSort
      files = Dir[File.join(LIB_ROOT, "**", "*.rb")].sort
      # rubocop:enable Lint/RedundantDirGlobSort
      files.each do |file|
        require file
      rescue StandardError, ScriptError => e
        report.load_failures[relative(file)] = e.class.name
      end
      files
    end

    def check_pattern0(entries, report)
      entries.each do |entry|
        late = entry.late_attribute_lines
        next if late.empty?

        report.pattern0_violations <<
          "#{relative(entry.file)}: #{entry.fqcn} declares attribute(s) " \
          "after xml do (line(s) #{late.join(', ')})"
      end
    end

    # Resolve parsed class names to Serializable classes, skipping classes
    # from files that failed to load (their runtime state is partial).
    # Returns fqcn => { klass:, xml_do: } where xml_do records whether any
    # source file for the class declares an xml do block (lutaml-model
    # fabricates default mappings for mapping-less classes, so the runtime
    # mapping alone cannot answer this).
    def resolve_models(entries)
      models = collect_models(entries)
      models.keep_if { |_fqcn, model| serializable?(model[:klass]) }
    end

    def collect_models(entries)
      broken = KNOWN_LOAD_FAILURES.keys
      entries.each_with_object({}) do |entry, hash|
        next if broken.include?(relative(entry.file))

        model = hash[entry.fqcn] ||= {
          klass: safe_const_get(entry.fqcn), xml_do: false
        }
        model[:xml_do] ||= entry.xml_do?
      end
    end

    def serializable?(klass)
      klass.is_a?(Class) && klass < Lutaml::Model::Serializable
    end

    def safe_const_get(fqcn)
      Object.const_get(fqcn)
    rescue NameError
      nil
    end

    # Checks 2-4: map targets resolve, declared attributes are mapped,
    # namespace declared. Only classes with an xml do block in source.
    def check_mappings(models, report)
      models.each do |fqcn, model|
        next unless model[:xml_do]

        mapping = model[:klass].mappings_for(:xml)
        check_targets(fqcn, model[:klass], mapping, report)
        check_namespace(fqcn, mapping, report)
      end
    end

    def check_targets(fqcn, klass, mapping, report)
      declared = klass.attributes.keys
      targets = mapping_targets(mapping)
      bad = targets - declared
      if bad.any?
        report.undeclared_targets << "#{fqcn} maps undeclared #{bad.inspect}"
      end
      unmapped = (declared - targets).sort_by(&:to_s)
      report.unmapped_attributes[fqcn] = unmapped if unmapped.any?
    end

    def mapping_targets(mapping)
      targets = mapping.elements.map(&:to) + mapping.attributes.map(&:to)
      targets << mapping.content_mapping.to if mapping.content_mapping
      targets.compact.uniq
    end

    def check_namespace(fqcn, mapping, report)
      return if mapping.namespace_uri
      return if %i[inherit blank].include?(mapping.namespace_param)

      report.missing_namespaces << fqcn
    end

    # Check 5: fresh-instance to_xml smoke for classes constructible
    # without required arguments and having a root element.
    def run_smoke(models, report)
      models.each do |fqcn, model|
        klass = model[:klass]
        next unless klass.mappings_for(:xml).root_element

        instance = build_instance(fqcn, klass, report)
        smoke_serialize(fqcn, instance, report) if instance
      end
    end

    def build_instance(fqcn, klass, report)
      klass.new
    rescue ArgumentError
      nil # requires constructor arguments: out of scope for this smoke
    rescue StandardError, ScriptError => e
      report.smoke_failures[fqcn] = e.class.name
      nil
    end

    def smoke_serialize(fqcn, instance, report)
      verdict = smoke_verdict(instance.to_xml)
      report.smoke_failures[fqcn] = verdict if verdict
    rescue StandardError, ScriptError => e
      report.smoke_failures[fqcn] = e.class.name
    end

    # @return [String, nil] failure label, nil when the XML is fine
    def smoke_verdict(xml)
      return "EmptyXmlOutput" if xml.to_s.strip.empty?

      document = Nokogiri::XML(xml.to_s, &:strict)
      "EmptyXmlOutput" if document.root.nil?
    end

    def relative(path)
      path.sub("#{LIB_ROOT}/", "lib/")
    end
  end
end

RSpec.describe Lint::ModelDefinitions do
  let(:report) { described_class.analysis }

  it "eager-loads every lib file outside the documented load-failure list" do
    expect(report.load_failures).to eq(described_class::KNOWN_LOAD_FAILURES)
  end

  # Pre-fix, this check flagged lib/uniword/revision.rb,
  # lib/uniword/comments_part.rb, lib/uniword/comment.rb,
  # lib/uniword/comment_range.rb, and lib/uniword/image.rb.
  it "declares attributes before the xml do block (Pattern 0)" do
    expect(report.pattern0_violations).to be_empty
  end

  it "maps only declared attributes in xml mappings" do
    expect(report.undeclared_targets).to be_empty
  end

  it "maps every declared attribute or whitelists it with a reason" do
    expect(report.unmapped_attributes).to eq(described_class.expected_unmapped)
  end

  it "declares a namespace in every xml do block" do
    expect(report.missing_namespaces).to be_empty
  end

  it "produces non-empty, well-formed XML from fresh model instances" do
    expect(report.smoke_failures).to eq(described_class::KNOWN_SMOKE_FAILURES)
  end
end
