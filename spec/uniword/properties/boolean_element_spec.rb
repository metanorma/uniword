# frozen_string_literal: true

require "spec_helper"

# ST_OnOff (ECMA-376 §17.17.4) spells off as "0", "false" or "off". Word
# shows all three as off. Every reader in the library has to agree on that,
# and so does every writer.
ns_decl = 'xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"'

# label => [written spelling, expected reading]
spellings = {
  "absent" => [nil, true],
  "1" => ["1", true],
  "0" => ["0", false],
  "true" => ["true", true],
  "false" => ["false", false],
  "on" => ["on", true],
  "off" => ["off", false],
  "empty" => ["", true],
  "garbage" => ["banana", true],
  "integer 1" => [1, true],
  "integer 0" => [0, false],
  "Ruby true" => [true, true],
  "Ruby false" => [false, false],
}.freeze

# Every rPr toggle, as [attribute, element name, predicate or nil].
#
# This list must cover Conversion::BOOLEAN_WRAPPERS exactly. It used to name
# ten of the fifteen, and the five it skipped — bold_cs, italic_cs,
# double_strike, no_proof, web_hidden — were the ones whose conversion could
# be deleted without a single spec noticing.
toggles = [
  [:bold, "b", :bold?],
  [:bold_cs, "bCs", nil],
  [:italic, "i", :italic?],
  [:italic_cs, "iCs", nil],
  [:strike, "strike", :strike?],
  [:double_strike, "dstrike", nil],
  [:small_caps, "smallCaps", :small_caps?],
  [:caps, "caps", :caps?],
  [:hidden, "vanish", :hidden?],
  [:no_proof, "noProof", nil],
  [:web_hidden, "webHidden", nil],
  [:shadow, "shadow", :shadow?],
  [:emboss, "emboss", :emboss?],
  [:imprint, "imprint", :imprint?],
  [:outline, "outline", :outline?],
].freeze

RSpec.describe Uniword::Properties::BooleanElement do
  # A toggle with no predicate method is still read the same way; ask the
  # wrapper directly so the table can cover every attribute.
  def reading(rpr, attr, predicate)
    return rpr.public_send(predicate) if predicate

    rpr.public_send(attr)&.on?
  end

  describe "the toggle list" do
    it "covers every attribute Conversion wraps" do
      wrapped = Uniword::Wordprocessingml::RunProperties::Conversion::BOOLEAN_WRAPPERS
      expect(toggles.map(&:first)).to match_array(wrapped.keys)
    end

    it "names the wrapper class each attribute converts to" do
      wrapped = Uniword::Wordprocessingml::RunProperties::Conversion::BOOLEAN_WRAPPERS
      toggles.each do |attr, _element, _predicate|
        rpr = Uniword::Wordprocessingml::RunProperties.new(attr => "1")
        expect(rpr.public_send(attr)).to be_a(wrapped.fetch(attr))
      end
    end
  end

  describe "reading a parsed toggle" do
    toggles.each do |attr, element, predicate|
      spellings.each do |label, (written, expected)|
        next if [1, 0, true, false].include?(written) # XML carries strings

        it "reads <w:#{element}> #{label} as #{expected} through every reader" do
          inner = written.nil? ? "<w:#{element}/>" : %(<w:#{element} w:val="#{written}"/>)
          rpr = Uniword::Wordprocessingml::RunProperties
            .from_xml(%(<w:rPr #{ns_decl}>#{inner}</w:rPr>))
          wrapper = rpr.public_send(attr)

          aggregate_failures do
            expect(wrapper.on?).to be(expected)
            expect(wrapper.value).to be(expected)
            expect(reading(rpr, attr, predicate)).to be(expected)
          end
        end
      end
    end
  end

  describe "writing a toggle" do
    toggles.each do |attr, _element, predicate|
      spellings.each do |label, (written, expected)|
        next if written.nil?

        it "writes #{attr} #{label} so it reads back as #{expected}" do
          rpr = Uniword::Wordprocessingml::RunProperties.new(attr => written)
          reparsed = Uniword::Wordprocessingml::RunProperties
            .from_xml(rpr.to_xml)

          aggregate_failures do
            expect(reading(rpr, attr, predicate)).to be(expected)
            expect(reading(reparsed, attr, predicate)).to be(expected)
          end
        end
      end
    end
  end

  describe "value:" do
    spellings.each do |label, (written, expected)|
      next if written.nil?

      it "treats value: #{label} as val: #{label}" do
        by_value = Uniword::Properties::Bold.new(value: written)
        by_val = Uniword::Properties::Bold.new(val: written)

        aggregate_failures do
          expect(by_value.val).to eq(by_val.val)
          expect(by_value.on?).to be(expected)
          expect(by_value.to_xml).to eq(by_val.to_xml)
        end
      end
    end

    it "lets an explicit val: win over value:" do
      bold = Uniword::Properties::Bold.new(val: "0", value: "1")
      expect(bold.on?).to be(false)
    end

    it "accepts a string 'value' key" do
      expect(Uniword::Properties::Bold.new("value" => "off").on?).to be(false)
    end
  end

  describe "#value=" do
    it "assigns through to val" do
      bold = Uniword::Properties::Bold.new
      bold.value = "off"
      expect(bold.val).to eq("off")
      expect(bold.on?).to be(false)
    end

    # value= has to go through val=, which is the setter that normalises a
    # Ruby boolean into the ST_OnOff spelling. Writing the ivar behind its
    # back leaves a bare false on the attribute, and then on? reads it as on
    # and to_xml has no string to render.
    it "normalises a Ruby boolean the way val= does" do
      off = Uniword::Properties::Bold.new
      off.value = false
      on = Uniword::Properties::Bold.new
      on.value = true

      aggregate_failures do
        expect(off.val).to eq("false")
        expect(off.on?).to be(false)
        expect(off.to_xml).to include('w:val="false"')
        expect(on.val).to be_nil
        expect(on.on?).to be(true)
        expect(on.to_xml).not_to include("w:val")
      end
    end
  end

  describe "round trips" do
    toggles.each do |attr, element, predicate|
      spellings.each do |label, (written, expected)|
        next if [1, 0, true, false].include?(written)

        it "keeps <w:#{element}> #{label} at #{expected} over two serialize cycles" do
          inner = written.nil? ? "<w:#{element}/>" : %(<w:#{element} w:val="#{written}"/>)
          first = Uniword::Wordprocessingml::RunProperties
            .from_xml(%(<w:rPr #{ns_decl}>#{inner}</w:rPr>))
          second = Uniword::Wordprocessingml::RunProperties.from_xml(first.to_xml)
          third = Uniword::Wordprocessingml::RunProperties.from_xml(second.to_xml)

          aggregate_failures do
            expect(reading(first, attr, predicate)).to be(expected)
            expect(reading(second, attr, predicate)).to be(expected)
            expect(reading(third, attr, predicate)).to be(expected)
          end
        end
      end
    end
  end

  describe "a Ruby false handed to RunProperties" do
    it "becomes an off toggle rather than a bare false" do
      rpr = Uniword::Wordprocessingml::RunProperties.new(bold: false)

      aggregate_failures do
        expect(rpr.bold).to be_a(Uniword::Properties::Bold)
        expect(rpr.bold?).to be(false)
        expect(rpr.to_xml).to include('w:val="false"')
      end
    end

    toggles.each do |attr, element, _predicate|
      it "serializes #{attr} set to a Ruby false" do
        rpr = Uniword::Wordprocessingml::RunProperties.new(attr => false)

        aggregate_failures do
          expect { rpr.to_xml }.not_to raise_error
          expect(rpr.to_xml).to match(%r{<(w:)?#{element} w:val="false"\s*/>})
        end
      end
    end
  end
end
