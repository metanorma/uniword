# frozen_string_literal: true

require "spec_helper"
require "fileutils"
require "set"
require "uniword/validation/rules"

RSpec.describe "DOCX repair verification" do
  let(:tmp_dir) { "tmp/repair_validation" }
  let(:html2doc_examples) { File.expand_path("../../../html2doc/spec/examples", __dir__) }

  before(:all) do
    FileUtils.mkdir_p("tmp/repair_validation")
  end

  def our_errors(path)
    ctx = Uniword::Validation::Rules::DocumentContext.new(path)
    Uniword::Validation::Rules::Registry.all.flat_map do |rule|
      rule.applicable?(ctx) ? rule.check(ctx) : []
    end.select { |i| i.severity == "error" && i.code.to_s.match?(/^DOC-10[0-9]$/) }
  ensure
    ctx&.close
  end

  def round_trip(source_path, output_path)
    doc = Uniword::DocumentFactory.from_file(source_path)
    doc.save(output_path)
  end

  repair_pairs = {
    minimal_fresh: "minimal_fresh.docx",
    minimal_fresh2: "minimal_fresh2.docx",
    minimal_fresh3: "minimal_fresh3.docx",
    minimal_fresh4: "minimal_fresh4.docx",
    minimal_helloworld: "minimal_helloworld.docx",
    minimal_helloworld_rt: "minimal_helloworld_roundtrip.docx",
    r7_numbering: "r7_swap_word_numbering_xml.docx",
    r8_numbering: "r8_swap_word_numbering_xml.docx",
    r9_numbering: "r9_swap_word_numbering_xml.docx",
    rice_roundtrip: "rice_roundtrip.docx",
    rice_roundtrip3: "rice_roundtrip3.docx",
    rice_roundtrip4: "rice_roundtrip4.docx",
    rice_roundtrip5: "rice_roundtrip5.docx",
    rice_roundtrip7: "rice_roundtrip7.docx",
    rice_roundtrip8: "rice_roundtrip8.docx",
    rice_roundtrip9: "rice_roundtrip9.docx",
    rice_roundtrip10: "rice_roundtrip10.docx",
    test_no_app: "test_no_app.docx",
    test_swap_riceapp: "test_swap_riceapp.docx",
  }.freeze

  # One test per pair — do the round-trip once and check all assertions
  repair_pairs.each do |_name, filename|
    it "repairs #{filename}: DOC-100..DOC-109 errors eliminated, " \
       "no more than Word, preserves paragraphs and text" do
      broken = File.join(html2doc_examples, filename)
      repaired = File.join(html2doc_examples, filename.sub(".docx", "_repaired.docx"))
      output = File.join(tmp_dir, "repair_#{filename}")

      skip "#{filename} not found" unless File.exist?(broken)

      # Load original for content comparison
      doc1 = Uniword::DocumentFactory.from_file(broken)
      original_paragraphs = doc1.paragraphs.count
      original_text = doc1.paragraphs.map { |p| p.text_content rescue "" }.join

      # Round-trip
      round_trip(broken, output)

      # Check: DOC-100..DOC-109 errors eliminated
      output_errors = our_errors(output)
      expect(output_errors).to be_empty,
        "#{filename} still has errors:\n" \
        "#{output_errors.map { |e| "  #{e.code}: #{e.message}" }.join("\n")}"

      # Check: no error codes that Word-repaired doesn't have
      if File.exist?(repaired)
        word_errors = our_errors(repaired)
        output_codes = output_errors.map(&:code).to_set
        word_codes = word_errors.map(&:code).to_set
        extra = output_codes - word_codes
        expect(extra).to be_empty,
          "Uniword output has error codes not in Word-repaired: #{extra.to_a.join(', ')}"
      end

      # Check: paragraph count preserved
      doc2 = Uniword::DocumentFactory.from_file(output)
      expect(doc2.paragraphs.count).to eq(original_paragraphs),
        "Paragraph count changed from #{original_paragraphs} to #{doc2.paragraphs.count}"

      # Check: text content preserved
      roundtrip_text = doc2.paragraphs.map { |p| p.text_content rescue "" }.join
      expect(roundtrip_text).to eq(original_text),
        "Text content changed after round-trip"
    end
  end
end
