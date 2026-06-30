# frozen_string_literal: true

require "spec_helper"

# These specs lock in fixes for Word "unreadable content" / "experienced an
# error trying to open the file" errors. Each spec maps to one OOXML schema
# violation that was previously emitted by Uniword's serialization layer.
RSpec.describe "OOXML structural invariants for Word compatibility" do
  describe Uniword::Ooxml::Namespaces::CustomProperties do
    # OOXML CT_CustomProperties uses prefix "custprops" at the element level
    # but the schema requires <property> attributes (fmtid, pid, name,
    # linkTarget) to be UNQUALIFIED — emitting them with the custprops:
    # prefix produces XML where the prefix is undeclared, which Word rejects.
    it "uses unqualified attribute form" do
      ns = described_class.new
      expect(ns.attribute_form_default).to eq(:unqualified),
        "CustomProperties attributes must be unqualified " \
        "(got #{ns.attribute_form_default.inspect})"
    end

    it "uses qualified element form" do
      ns = described_class.new
      expect(ns.element_form_default).to eq(:qualified),
        "CustomProperties elements must be qualified"
    end
  end

  describe "CustomProperties XML serialization" do
    let(:props) do
      cp = Uniword::Ooxml::CustomProperties.new
      cp.properties << Uniword::Ooxml::CustomProperty.new(
        fmtid: "{D5CDD505-2E9C-101B-9397-08002B2CF9AE}",
        pid: 2,
        name: "TestProp",
        lpwstr: Uniword::Ooxml::Types::VariantTypes::VtLpwstr.new(value: "hello"),
      )
      cp
    end

    it "emits <property> attributes without custprops: prefix" do
      xml = props.to_xml
      expect(xml).to include('fmtid='), "fmtid should be unqualified"
      expect(xml).to include('pid='), "pid should be unqualified"
      expect(xml).to include('name='), "name should be unqualified"
      expect(xml).not_to match(/custprops:/),
        "custprops: prefix must NOT appear on attributes; " \
        "Word rejects it as an undeclared prefix. XML: #{xml}"
    end

    it "round-trips cleanly through Nokogiri strict parsing" do
      xml = props.to_xml
      expect { Nokogiri::XML(xml) { |c| c.strict } }.not_to raise_error
      doc = Nokogiri::XML(xml) { |c| c.strict }
      expect(doc.errors).to be_empty,
        "custom.xml must be strict-XML clean: #{doc.errors.map(&:message).inspect}"
    end
  end

  describe Uniword::Wordprocessingml::Settings do
    # CT_Settings is an OOXML sequence type. The element order declared in
    # the model's map_element block drives serialization order, so the
    # block MUST mirror the schema. Out-of-order elements cause Word to
    # report "unreadable content".
    let(:settings) do
      s = described_class.new
      s.zoom = Uniword::Wordprocessingml::Zoom.new(percent: "110")
      s.mirror_margins = Uniword::Wordprocessingml::MirrorMargins.new
      s.proof_state = Uniword::Wordprocessingml::ProofState.new(spelling: "clean")
      s.default_tab_stop = Uniword::Wordprocessingml::DefaultTabStop.new(val: "720")
      s.hyphenation_zone = Uniword::Wordprocessingml::HyphenationZone.new(val: "425")
      s.even_and_odd_headers = Uniword::Wordprocessingml::EvenAndOddHeaders.new
      s.character_spacing_control =
        Uniword::Wordprocessingml::CharacterSpacingControl.new(val: "doNotCompress")
      s.compat = Uniword::Wordprocessingml::Compat.new
      s.rsids = Uniword::Wordprocessingml::Rsids.new
      s.math_pr = Uniword::Wordprocessingml::MathPr.new
      s.theme_font_lang = Uniword::Wordprocessingml::ThemeFontLang.new(val: "nl-NL")
      s.clr_scheme_mapping = Uniword::Wordprocessingml::ClrSchemeMapping.new
      s.shape_defaults = Uniword::Wordprocessingml::ShapeDefaults.new
      s.decimal_symbol = Uniword::Wordprocessingml::DecimalSymbol.new(val: ".")
      s.list_separator = Uniword::Wordprocessingml::ListSeparator.new(val: ",")
      s
    end

    it "emits mirrorMargins before proofState" do
      xml = settings.to_xml
      mm_idx = xml.index("<mirrorMargins")
      ps_idx = xml.index("<proofState")
      expect(mm_idx).to be < ps_idx
    end

    it "emits hyphenationZone after defaultTabStop" do
      xml = settings.to_xml
      dts_idx = xml.index("<defaultTabStop")
      hz_idx = xml.index("<hyphenationZone")
      expect(hz_idx).to be > dts_idx
    end

    it "emits compat after characterSpacingControl" do
      xml = settings.to_xml
      csc_idx = xml.index("<characterSpacingControl")
      compat_idx = xml.index(/<compat[ >\/]/)
      expect(compat_idx).to be > csc_idx
    end
  end

  describe Uniword::Wordprocessingml::SectionProperties do
    # CT_SectPr requires pgNumType to precede cols. Wrong order produces
    # "Word experienced an error trying to open the file" — a hard open
    # failure with no recovery prompt.
    let(:sect_pr) do
      s = described_class.new
      s.page_size = Uniword::Wordprocessingml::PageSize.new(width: "11906", height: "16838")
      s.page_margins = Uniword::Wordprocessingml::PageMargins.new(
        top: "794", bottom: "567", left: "1077", right: "1077",
        header: "720", footer: "720", gutter: "0",
      )
      s.page_numbering = Uniword::Wordprocessingml::PageNumbering.new(start: "1")
      s.columns = Uniword::Wordprocessingml::Columns.new(space: "720")
      s.doc_grid = Uniword::Wordprocessingml::DocGrid.new(line_pitch: "360")
      s
    end

    it "emits pgNumType before cols" do
      xml = sect_pr.to_xml
      pn_idx = xml.index("<pgNumType")
      cols_idx = xml.index("<cols")
      expect(pn_idx).not_to be_nil
      expect(cols_idx).not_to be_nil
      expect(pn_idx).to be < cols_idx,
        "pgNumType must precede cols in sectPr, got: #{xml}"
    end
  end
end