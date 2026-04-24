# frozen_string_literal: true

require "spec_helper"
require "uniword/diff/package_differ"

RSpec.describe Uniword::Diff::PackageDiffer, "Word repair stats analysis" do
  # Fixtures: uniword-generated DOCX (pre-repair) vs same file opened & saved
  # by Microsoft Word (repaired). Word reports "Summary Info 1 is invalid" on
  # the pre-repair files and silently fixes them on save.
  #
  # This spec analyses what Word changes systematically, serving as a
  # regression baseline for uniword DOCX generation quality.

  FIXTURE_PAIRS = {
    "01_single_word" => %w[spec/fixtures/01_single_word.docx spec/fixtures/01_single_word-repaired.docx],
    "02_two_words" => %w[spec/fixtures/02_two_words.docx spec/fixtures/02_two_words-repaired.docx],
    "03_two_paragraphs" => %w[spec/fixtures/03_two_paragraphs.docx spec/fixtures/03_two_paragraphs-repaired.docx],
    "04_with_empty_para" => %w[spec/fixtures/04_with_empty_para.docx spec/fixtures/04_with_empty_para-repaired.docx],
    "05_longer_text" => %w[spec/fixtures/05_longer_text.docx spec/fixtures/05_longer_text-repaired.docx],
    "06_cjk_text" => %w[spec/fixtures/06_cjk_text.docx spec/fixtures/06_cjk_text-repaired.docx],
  }.freeze

  # Compute all diffs once and share across tests.
  let(:all_results) do
    FIXTURE_PAIRS.to_h do |label, (pre, repaired)|
      [label, described_class.new(pre, repaired, canon: true).diff]
    end
  end

  # ── Stats helper ──────────────────────────────────────────────────────

  # Aggregate a metric across all fixture pairs.
  # Yields (label, result) and collects truthy returns.
  def aggregate
    all_results.filter_map { |label, r| [label, yield(label, r)] if yield(label, r) }
  end

  # ── 1. Which parts does Word always modify? ───────────────────────────

  describe "parts modified by Word repair" do
    it "Word modifies at least 10 parts per file" do
      all_results.each do |label, result|
        expect(result.modified_parts.size).to be >= 10,
          "#{label}: expected >= 10 modified parts, got #{result.modified_parts.size}"
      end
    end

    it "Word always modifies the same core XML parts" do
      always_modified = %w[
        [Content_Types].xml
        _rels/.rels
        docProps/app.xml
        docProps/core.xml
        word/_rels/document.xml.rels
        word/document.xml
        word/fontTable.xml
        word/settings.xml
        word/styles.xml
        word/theme/theme1.xml
        word/webSettings.xml
      ]

      all_results.each do |label, result|
        modified_names = result.modified_parts.to_set(&:name)
        always_modified.each do |part|
          expect(modified_names).to include(part),
            "#{label}: expected #{part} to be modified"
        end
      end
    end

    it "Word never adds or removes parts (only modifies)" do
      all_results.each do |label, result|
        expect(result.added_parts).to be_empty,
          "#{label}: unexpected added parts: #{result.added_parts}"
        expect(result.removed_parts).to be_empty,
          "#{label}: unexpected removed parts: #{result.removed_parts}"
      end
    end
  end

  # ── 2. Canon semantic analysis ────────────────────────────────────────

  describe "Canon semantic comparison" do
    it "webSettings.xml is always canon-equivalent (only whitespace)" do
      all_results.each do |label, result|
        ws = result.modified_parts.find { |p| p.name == "word/webSettings.xml" }
        expect(ws).not_to be_nil, "#{label}: webSettings.xml not in modified parts"
        expect(ws.canon_equivalent).to be(true),
          "#{label}: webSettings.xml should be canon-equivalent"
      end
    end

    it "these parts are always canon-different" do
      always_different = %w[
        word/document.xml
        word/fontTable.xml
        word/settings.xml
        word/styles.xml
        word/theme/theme1.xml
      ]

      all_results.each do |label, result|
        always_different.each do |part_name|
          part = result.modified_parts.find { |p| p.name == part_name }
          expect(part).not_to be_nil, "#{label}: #{part_name} not in modified parts"
          expect(part.canon_equivalent).to be(false),
            "#{label}: #{part_name} should be canon-different"
        end
      end
    end

    it "canon_summary is set on every canon-different part" do
      all_results.each do |label, result|
        result.modified_parts.select { |p| p.canon_equivalent == false }.each do |p|
          expect(p.canon_summary).to be_a(String),
            "#{label}: missing canon_summary for #{p.name}"
        end
      end
    end
  end

  # ── 3. Theme expansion ────────────────────────────────────────────────

  describe "theme1.xml expansion" do
    it "Word always expands the minimal theme to a full theme" do
      all_results.each do |label, result|
        theme = result.modified_parts.find { |p| p.name == "word/theme/theme1.xml" }
        expect(theme).not_to be_nil
        expect(theme.size_delta).to be > 5000,
          "#{label}: theme only grew by #{theme.size_delta} bytes"
        expect(theme.new_size).to be > 8000,
          "#{label}: repaired theme only #{theme.new_size} bytes"
      end
    end
  end

  # ── 4. styles.xml cleanup ────────────────────────────────────────────

  describe "styles.xml cleanup" do
    it "Word always removes empty kern/sz/szCs elements from docDefaults" do
      all_results.each do |label, result|
        styles = result.modified_parts.find { |p| p.name == "word/styles.xml" }
        element_changes = styles.changes.select { |c| c.category == :element_count }
        removed = element_changes.select { |c| c.description.match?(/kern|sz|szCs/) }
        expect(removed).not_to be_empty,
          "#{label}: expected kern/sz/szCs removal in styles.xml"
      end
    end

    it "styles.xml always shrinks" do
      all_results.each do |label, result|
        styles = result.modified_parts.find { |p| p.name == "word/styles.xml" }
        expect(styles.size_delta).to be < 0,
          "#{label}: styles.xml grew by #{styles.size_delta} instead of shrinking"
      end
    end
  end

  # ── 5. fontTable.xml cleanup ──────────────────────────────────────────

  describe "fontTable.xml cleanup" do
    it "Word always replaces empty sig elements with notTrueType" do
      all_results.each do |label, result|
        ft = result.modified_parts.find { |p| p.name == "word/fontTable.xml" }
        ntt = ft.changes.find { |c| c.description.include?("notTrueType") }
        expect(ntt).not_to be_nil,
          "#{label}: expected notTrueType change in fontTable.xml"
      end
    end

    it "sig element count always decreases" do
      all_results.each do |label, result|
        ft = result.modified_parts.find { |p| p.name == "word/fontTable.xml" }
        sig_change = ft.changes.find { |c| c.description.match?(/sig: \d+ -> \d+/) }
        expect(sig_change).not_to be_nil, "#{label}: no sig element count change"
        old, new_val = sig_change.description.match(/(\d+) -> (\d+)/)[1..2].map(&:to_i)
        expect(new_val).to be < old,
          "#{label}: sig count went #{old} -> #{new_val}, expected decrease"
      end
    end

    it "fontTable.xml always shrinks" do
      all_results.each do |label, result|
        ft = result.modified_parts.find { |p| p.name == "word/fontTable.xml" }
        expect(ft.size_delta).to be < 0,
          "#{label}: fontTable.xml grew by #{ft.size_delta}"
      end
    end
  end

  # ── 6. settings.xml changes ──────────────────────────────────────────

  describe "settings.xml changes" do
    it "Word always adds rsid elements" do
      all_results.each do |label, result|
        settings = result.modified_parts.find { |p| p.name == "word/settings.xml" }
        rsid_change = settings.changes.find { |c| c.description.match?(/rsid: \d+ -> \d+/) }
        expect(rsid_change).not_to be_nil,
          "#{label}: no rsid element count change in settings.xml"
        old, new_val = rsid_change.description.match(/(\d+) -> (\d+)/)[1..2].map(&:to_i)
        expect(new_val).to be > old,
          "#{label}: rsid count went #{old} -> #{new_val}, expected increase"
      end
    end

    it "Word always removes doNotDisplayPageBoundaries" do
      all_results.each do |label, result|
        settings = result.modified_parts.find { |p| p.name == "word/settings.xml" }
        dndpb = settings.changes.find { |c| c.description.include?("doNotDisplayPageBoundaries") }
        expect(dndpb).not_to be_nil,
          "#{label}: no doNotDisplayPageBoundaries change in settings.xml"
        expect(dndpb.description).to match(/1 -> 0/),
          "#{label}: expected doNotDisplayPageBoundaries 1 -> 0, got: #{dndpb.description}"
      end
    end
  end

  # ── 7. ZIP metadata patterns ──────────────────────────────────────────

  describe "ZIP metadata" do
    it "every entry flips internal_attr from text to binary" do
      all_results.each do |label, result|
        expect(result.zip_metadata_changes).not_to be_empty,
          "#{label}: no ZIP metadata changes found"

        result.zip_metadata_changes.each do |mc|
          expect(mc.differences[:internal_attr]).to eq(%w[text binary]),
            "#{label}: #{mc.part} internal_attr is #{mc.differences[:internal_attr].inspect}, expected ['text', 'binary']"
        end
      end
    end

    it "Word resets all timestamps to 1980-01-01 (DOS epoch)" do
      all_results.each do |label, result|
        result.zip_metadata_changes.each do |mc|
          next unless mc.differences[:timestamp]

          _old, new_val = mc.differences[:timestamp]
          expect(new_val).to include("1980-01-01"),
            "#{label}: #{mc.part} repaired timestamp is #{new_val}, expected 1980-01-01"
        end
      end
    end

    it "every ZIP entry has metadata changes (no exceptions)" do
      all_results.each do |label, result|
        metadata_parts = result.zip_metadata_changes.to_set(&:part)
        modified_parts = result.modified_parts.to_set(&:name)
        expect(metadata_parts).to eq(modified_parts),
          "#{label}: metadata changes don't cover all modified parts. " \
          "Missing: #{modified_parts - metadata_parts}"
      end
    end
  end

  # ── 8. OPC validation ─────────────────────────────────────────────────

  describe "OPC validation" do
    it "both pre-repair and repaired files have no OPC issues" do
      all_results.each do |label, result|
        expect(result.opc_issues).to be_empty,
          "#{label}: unexpected OPC issues: #{result.opc_issues.map(&:description)}"
      end
    end
  end

  # ── 9. docProps changes ───────────────────────────────────────────────

  describe "docProps changes" do
    it "core.xml is always canon-different (metadata timestamps change)" do
      all_results.each do |label, result|
        core = result.modified_parts.find { |p| p.name == "docProps/core.xml" }
        expect(core).not_to be_nil
        expect(core.canon_equivalent).to be(false),
          "#{label}: core.xml should be canon-different"
        expect(core.canon_summary).to include("lastModifiedBy"),
          "#{label}: core.xml canon_summary should mention lastModifiedBy"
      end
    end

    it "app.xml is always canon-different (word/character counts change)" do
      all_results.each do |label, result|
        app = result.modified_parts.find { |p| p.name == "docProps/app.xml" }
        expect(app).not_to be_nil
        expect(app.canon_equivalent).to be(false),
          "#{label}: app.xml should be canon-different"
      end
    end
  end

  # ── 10. Summary stats table ───────────────────────────────────────────

  describe "summary statistics" do
    it "prints a human-readable stats table (docstring test)" do
      stats = all_results.to_h do |label, result|
        modified = result.modified_parts
        canon_eq = modified.count { |p| p.canon_equivalent == true }
        canon_diff = modified.count { |p| p.canon_equivalent == false }
        canon_na = modified.count { |p| p.canon_equivalent.nil? }

        [label, {
          modified: modified.size,
          canon_eq: canon_eq,
          canon_diff: canon_diff,
          canon_na: canon_na,
          zip_meta: result.zip_metadata_changes.size,
          opc_issues: result.opc_issues.size,
        }]
      end

      # Verify every pair has the same structural pattern
      stat_values = stats.values
      modified_counts = stat_values.map { |s| s[:modified] }
      canon_eq_counts = stat_values.map { |s| s[:canon_eq] }

      expect(modified_counts.uniq.size).to eq(1),
        "Not all files have same modified count: #{modified_counts}"
      expect(canon_eq_counts.uniq.size).to eq(1),
        "Not all files have same canon-equivalent count: #{canon_eq_counts}"
      expect(stat_values.all? { |s| s[:opc_issues] == 0 }).to be true

      table_lines = ["\n  Word repair stats analysis (#{FIXTURE_PAIRS.size} pairs):"]
      table_lines << "  #{'Fixture'.ljust(22)} #{'Mod'.rjust(4)} #{'CEq'.rjust(4)} #{'CDif'.rjust(4)} #{'CNA'.rjust(4)} #{'ZIP'.rjust(4)} #{'OPC'.rjust(4)}"
      table_lines << "  #{'-' * 50}"
      stats.each do |label, s|
        table_lines << "  #{label.ljust(22)} #{s[:modified].to_s.rjust(4)} #{s[:canon_eq].to_s.rjust(4)} #{s[:canon_diff].to_s.rjust(4)} #{s[:canon_na].to_s.rjust(4)} #{s[:zip_meta].to_s.rjust(4)} #{s[:opc_issues].to_s.rjust(4)}"
      end
      # This output appears when running with --format documentation
      expect(table_lines.join("\n")).to include("Word repair stats")
    end
  end
end
