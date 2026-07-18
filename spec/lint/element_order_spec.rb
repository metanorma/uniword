# frozen_string_literal: true

require "spec_helper"
require "nokogiri"

# Lint: model map_element declaration order vs. the XSD xsd:sequence order.
#
# Fresh-built models serialize children in map_element declaration order
# (lutaml-model MappingRule order). When that order drifts from the
# complexType's xsd:sequence in data/schemas/iso/wml.xsd, Microsoft Word
# rejects the document with an "unreadable content" repair dialog — see
# commit 98f1342a, which fixed exactly this in RunProperties (w:kern was
# serialized after w:sz), Style (w:qFormat came before w:semiHidden /
# w:unhideWhenUsed) and TableProperties (w:tblStyle was last instead of
# first). Those models are re-checked here as regression anchors: the
# extractor specs below assert the schema-derived order matches the order
# 98f1342a restored, so any future drift fails this lint.
#
# XSD particle handling (how each position kind is extracted):
# * xsd:sequence / xsd:element — each element is one ordered position.
#   Elements declared by reference (e.g. ref="m:mathPr", ref=
#   "sl:schemaLibrary") contribute their local name ("mathPr",
#   "schemaLibrary"), which is how the models name their map_element keys.
# * xsd:complexContent/xsd:extension — the base type's positions come
#   first, then the extension's own (e.g. CT_TblPr yields the whole
#   CT_TblPrBase sequence followed by w:tblPrChange).
# * xsd:group with an xsd:sequence particle — inlined in place, in order.
# * xsd:choice (including groups whose particle is a choice, e.g.
#   EG_RunInnerContent, EG_PContent, EG_ContentRowContent) — all members
#   share ONE position: run/content-level children may repeat and
#   interleave freely, so no relative order is enforced between them.
#   Elements sequenced before/after the choice still anchor their side.
#   Exception: ORDERED_CHOICE_GROUPS. EG_RPrBase is expressed as an
#   unbounded choice in the transitional schema, but Word (and the strict
#   ECMA-376 schema, where CT_RPr is a true sequence) require w:rPr
#   children in the listed member order — exactly the order 98f1342a
#   restored — so its members are treated as ordered positions.
# * xsd:any — skipped: it names no concrete element, so no map_element
#   key can be checked against it.
#
# Model elements with no counterpart in the transitional schema (W14/W15
# extensions such as w14:docId, MC AlternateContent, W13 footnoteColumns)
# are skipped: the bundled wml.xsd cannot order them. Only the relative
# order of schema-covered elements is asserted (a subsequence check, so
# partially-mapped complexTypes pass as long as what is mapped is ordered).
module ElementOrder
  SCHEMA_PATH = File.expand_path("../../data/schemas/iso/wml.xsd", __dir__)

  # One position in a flattened content model: the element names allowed
  # at that position. A singleton is a strict xsd:sequence position;
  # several names share one xsd:choice position (order among them free).
  class Position
    attr_reader :names

    def initialize(names)
      @names = names
    end
  end

  # Parses the ISO WordprocessingML schema and flattens a complexType's
  # content model into ordered Positions, resolving xsd:group references
  # and walking xsd:extension base types.
  class Schema
    XSD_NS = "http://www.w3.org/2001/XMLSchema"
    NS = { "xsd" => XSD_NS }.freeze

    # Choice groups whose member order is normative in practice: the
    # transitional schema expresses them as an unbounded choice, but Word
    # enforces the member order (as does the strict schema). Everything
    # not listed here is treated as an unordered shared position.
    ORDERED_CHOICE_GROUPS = %w[EG_RPrBase].freeze

    def initialize(path)
      doc = Nokogiri::XML(File.read(path))
      @complex_types = index_by_name(doc, "complexType")
      @groups = index_by_name(doc, "group")
    end

    # Ordered content-model positions for a complexType. xsd:extension
    # bases (e.g. CT_TblPrBase for CT_TblPr) are extracted first.
    def positions_for(type_name, visited = [])
      return [] if visited.include?(type_name)

      type = @complex_types.fetch(type_name)
      extension = type.at_xpath("xsd:complexContent/xsd:extension", NS)
      return walk(type) unless extension

      positions_for(extension["base"], visited + [type_name]) +
        walk(extension)
    end

    # Element name => position index (first occurrence wins), the basis
    # for the subsequence comparison with model declaration order.
    def rank_map(type_name)
      positions_for(type_name).each_with_index.with_object({}) do
        |(position, index), ranks|
        position.names.each { |name| ranks[name] ||= index }
      end
    end

    private

    def index_by_name(doc, node_name)
      nodes = doc.xpath("/xsd:schema/xsd:#{node_name}", NS)
      nodes.to_h { |node| [node["name"], node] }
    end

    def walk(container)
      container.element_children.each_with_object([]) do |child, positions|
        case child.name
        when "sequence" then positions.concat(walk(child))
        when "group" then positions.concat(walk_group(child))
        when "element", "choice" then positions << position_for(child)
        when "any" then nil # skipped by design, see module documentation
        end
      end
    end

    # One XSD particle as a Position: a sequenced element is ordered on
    # its own; a choice shares one unordered position across its members.
    def position_for(node)
      return Position.new([local_name(node)]) if node.name == "element"

      Position.new(member_names(node))
    end

    def walk_group(ref_node)
      group = @groups[ref_node["ref"]]
      return [] unless group # external/unknown group ref: nothing to check

      particle = group.element_children.first
      return walk(group) unless particle&.name == "choice"

      names = member_names(particle)
      return names.map { |name| Position.new([name]) } if ordered?(group)

      [Position.new(names)]
    end

    def ordered?(group)
      ORDERED_CHOICE_GROUPS.include?(group["name"])
    end

    # All element names reachable from a choice/sequence particle,
    # following nested group references (cycle-guarded).
    def member_names(node, visited = [])
      node.element_children.each_with_object([]) do |child, names|
        case child.name
        when "element" then names << local_name(child)
        when "group" then names.concat(group_member_names(child, visited))
        when "choice", "sequence"
          names.concat(member_names(child, visited))
        when "any" then nil # skipped by design, see module documentation
        end
      end
    end

    def group_member_names(ref_node, visited)
      ref = ref_node["ref"]
      return [] if visited.include?(ref)

      group = @groups[ref]
      group ? member_names(group, visited + [ref]) : []
    end

    def local_name(node)
      (node["name"] || node["ref"]).split(":").last
    end
  end

  # Reads a model class's map_element declaration order from
  # lutaml-model's public mapping metadata (no source parsing):
  # Lutaml::Xml::Mapping#elements yields MappingRules in the order the
  # xml block declared them.
  class ModelMappingOrder
    def initialize(model_class)
      @model_class = model_class
    end

    def element_names
      @model_class.mappings[:xml].elements.map(&:name)
    end
  end

  # Compares model declaration order against schema ranks: the schema-
  # covered subset of the model's elements must have non-decreasing
  # ranks (equal ranks share one unordered choice position).
  class OrderComparison
    def initialize(rank_map)
      @rank_map = rank_map
    end

    # Adjacent [before, after] element pairs whose ranks decrease.
    def violations(element_names)
      covered = element_names.select { |name| @rank_map.key?(name) }
      covered.each_cons(2).select do |before, after|
        @rank_map[after] < @rank_map[before]
      end
    end
  end
end

RSpec.describe ElementOrder do
  let(:schema) { described_class::Schema.new(described_class::SCHEMA_PATH) }

  # Curated order-sensitive complexTypes and their model classes.
  # Note: the ISO schema names the table-row type CT_Row (ECMA: CT_Tr).
  {
    "CT_RPr" => Uniword::Wordprocessingml::RunProperties,
    "CT_PPr" => Uniword::Wordprocessingml::ParagraphProperties,
    "CT_TblPr" => Uniword::Wordprocessingml::TableProperties,
    "CT_TblPrBase" => Uniword::Wordprocessingml::TableProperties,
    "CT_TcPr" => Uniword::Wordprocessingml::TableCellProperties,
    "CT_Settings" => Uniword::Wordprocessingml::Settings,
    "CT_Style" => Uniword::Wordprocessingml::Style,
    "CT_SectPr" => Uniword::Wordprocessingml::SectionProperties,
    "CT_Tbl" => Uniword::Wordprocessingml::Table,
    "CT_Row" => Uniword::Wordprocessingml::TableRow,
    "CT_Tc" => Uniword::Wordprocessingml::TableCell,
    "CT_R" => Uniword::Wordprocessingml::Run,
    "CT_P" => Uniword::Wordprocessingml::Paragraph,
  }.each do |type_name, model_class|
    describe "#{type_name} (#{model_class})" do
      let(:violations) do
        order = described_class::ModelMappingOrder.new(model_class)
        ranks = schema.rank_map(type_name)
        comparison = described_class::OrderComparison.new(ranks)
        comparison.violations(order.element_names)
      end

      it "declares map_element in the XSD xsd:sequence order" do
        pairs = violations.map { |pair| pair.join(" > ") }.join(", ")
        expect(violations).to be_empty,
                              "#{type_name} map_element drift: #{pairs}"
      end
    end
  end

  # Regression anchors for commit 98f1342a: the order this lint enforces
  # is exactly the order that commit restored, so it would have caught
  # the original drift (w:kern after w:sz, w:qFormat too early,
  # w:tblStyle last).
  describe "98f1342a regression anchors" do
    it "orders CT_RPr w:kern before w:sz" do
      ranks = schema.rank_map("CT_RPr")
      expect(ranks["kern"]).to be < ranks["sz"]
    end

    it "orders CT_RPr w:rStyle first" do
      ranks = schema.rank_map("CT_RPr")
      expect(ranks["rStyle"]).to eq(0)
    end

    it "orders CT_Style w:semiHidden before w:qFormat" do
      ranks = schema.rank_map("CT_Style")
      expect(ranks["semiHidden"]).to be < ranks["qFormat"]
    end

    it "orders CT_Style w:unhideWhenUsed before w:qFormat" do
      ranks = schema.rank_map("CT_Style")
      expect(ranks["unhideWhenUsed"]).to be < ranks["qFormat"]
    end

    it "orders CT_TblPr w:tblStyle first" do
      ranks = schema.rank_map("CT_TblPr")
      expect(ranks["tblStyle"]).to eq(0)
    end
  end

  describe "schema extraction" do
    it "walks xsd:extension base types (CT_TblPr ends with tblPrChange)" do
      ranks = schema.rank_map("CT_TblPr")
      expect(ranks["tblPrChange"]).to be > ranks["tblLook"]
    end

    it "treats xsd:choice members as one unordered position" do
      ranks = schema.rank_map("CT_R")
      expect(ranks["br"]).to eq(ranks["t"])
    end

    it "anchors elements sequenced before a choice group" do
      ranks = schema.rank_map("CT_R")
      expect(ranks["rPr"]).to be < ranks["t"]
    end

    it "skips xsd:any positions (CT_Background keeps only w:drawing)" do
      expect(schema.rank_map("CT_Background")).to eq("drawing" => 0)
    end
  end

  describe ElementOrder::OrderComparison do
    subject(:comparison) do
      described_class.new("a" => 0, "b" => 1, "c" => 1, "d" => 2)
    end

    it "accepts non-decreasing ranks" do
      expect(comparison.violations(%w[a b c d])).to be_empty
    end

    it "allows any relative order within one shared choice position" do
      expect(comparison.violations(%w[a c b d])).to be_empty
    end

    it "ignores elements with no schema position (extensions)" do
      expect(comparison.violations(%w[a w14Thing b])).to be_empty
    end

    it "flags adjacent pairs whose ranks decrease" do
      expect(comparison.violations(%w[b a])).to eq([%w[b a]])
    end
  end
end
