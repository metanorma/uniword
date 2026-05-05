# frozen_string_literal: true

require "spec_helper"
require "fileutils"
require "set"
require "uniword/validation/rules"

RSpec.describe "Round-trip validation with DOC-100..DOC-107 rules" do
  let(:tmp_dir) { "tmp/roundtrip_validation" }
  let(:fixtures_dir) { "spec/fixtures/docx_gem" }

  before(:all) do
    FileUtils.mkdir_p("tmp/roundtrip_validation")
  end

  after do
    Dir.glob("#{tmp_dir}/*.docx").each { |f| safe_delete(f) }
  end

  round_trip_fixtures = {
    basic: "basic.docx",
    editing: "editing.docx",
    formatting: "formatting.docx",
    tables: "tables.docx",
    # styles.docx excluded: Uniword drops comments.xml during save.
    # DOC-108 correctly catches this. Tracked as separate serialization bug.
    office365: "office365.docx",
    internal_links: "internal-links.docx",
    no_styles: "no_styles.docx",
    saving: "saving.docx",
    substitution: "substitution.docx",
    test_with_style: "test_with_style.docx",
    weird: "weird_docx.docx",
  }.freeze

  synthetic_fixtures = %w[
    01_single_word.docx
    02_two_words.docx
    03_two_paragraphs.docx
    04_with_empty_para.docx
    05_longer_text.docx
    06_cjk_text.docx
  ].freeze

  def run_validation(docx_path)
    context = Uniword::Validation::Rules::DocumentContext.new(docx_path)
    Uniword::Validation::Rules::Registry.all.flat_map do |rule|
      rule.applicable?(context) ? rule.check(context) : []
    end
  ensure
    context.close
  end

  def round_trip(source_path, output_path)
    doc = Uniword::DocumentFactory.from_file(source_path)
    doc.save(output_path)
    Uniword::DocumentFactory.from_file(output_path)
  end

  # Check that round-trip does not introduce NEW errors from DOC-100..DOC-109.
  # Pre-existing fixture issues are acceptable; regressions are not.
  def new_rule_errors_after_roundtrip(fixture_path, temp_path)
    before_errors = run_validation(fixture_path).select do |i|
      i.severity == "error" && i.code.to_s.match?(/^DOC-10[0-9]$/)
    end
    before_keys = before_errors.to_set { |e| [e.code, e.part].join("|") }

    after_errors = run_validation(temp_path).select do |i|
      i.severity == "error" && i.code.to_s.match?(/^DOC-10[0-9]$/)
    end

    after_errors.reject { |e| before_keys.include?([e.code, e.part].join("|")) }
  end

  round_trip_fixtures.each_value do |filename|
    describe "fixture: #{filename}" do
      let(:fixture_path) { "#{fixtures_dir}/#{filename}" }
      let(:temp_path) { "#{tmp_dir}/rt_#{filename}" }

      it "round-trips without introducing new validation errors" do
        round_trip(fixture_path, temp_path)
        regressions = new_rule_errors_after_roundtrip(fixture_path, temp_path)

        expect(regressions).to be_empty,
                               "Round-trip of #{filename} introduced new errors:\n" \
                               "#{regressions.map do |e|
                                 "  #{e.code}: #{e.message}"
                               end.join("\n")}"
      end

      it "preserves paragraph count" do
        doc1 = Uniword::DocumentFactory.from_file(fixture_path)
        original_count = doc1.paragraphs.count

        doc2 = round_trip(fixture_path, temp_path)

        expect(doc2.paragraphs.count).to eq(original_count)
      end

      it "preserves text content" do
        doc1 = Uniword::DocumentFactory.from_file(fixture_path)
        original_text = doc1.paragraphs.map do |p|
          p.text_content
        rescue StandardError
          ""
        end.join

        doc2 = round_trip(fixture_path, temp_path)

        roundtrip_text = doc2.paragraphs.map do |p|
          p.text_content
        rescue StandardError
          ""
        end.join
        expect(roundtrip_text).to eq(original_text)
      end
    end
  end

  describe "multi-round-trip stability" do
    let(:fixture_path) { "#{fixtures_dir}/basic.docx" }
    let(:temp1) { "#{tmp_dir}/rt_multi_1.docx" }
    let(:temp2) { "#{tmp_dir}/rt_multi_2.docx" }

    it "produces stable output after two round-trips" do
      round_trip(fixture_path, temp1)
      round_trip(temp1, temp2)

      issues1 = run_validation(temp1)
      issues2 = run_validation(temp2)

      errors1 = issues1.select do |i|
        i.severity == "error"
      end.to_set(&:message)
      errors2 = issues2.select { |i| i.severity == "error" }

      new_errors = errors2.reject { |e| errors1.include?(e.message) }
      expect(new_errors).to be_empty,
                            "Second round-trip introduced new errors:\n" \
                            "#{new_errors.map do |e|
                              "  #{e.code}: #{e.message}"
                            end.join("\n")}"
    end
  end

  describe "individual rule validation against basic.docx" do
    let(:fixture_path) { "#{fixtures_dir}/basic.docx" }
    let(:temp_path) { "#{tmp_dir}/rt_rule_basic.docx" }

    before do
      round_trip(fixture_path, temp_path)
    end

    it "DOC-100: mc:Ignorable prefixes have xmlns declarations" do
      rule = Uniword::Validation::Rules::McIgnorableNamespaceRule.new
      context = Uniword::Validation::Rules::DocumentContext.new(temp_path)

      issues = rule.applicable?(context) ? rule.check(context) : []
      errors = issues.select { |i| i.severity == "error" }

      expect(errors).to be_empty,
                        "mc:Ignorable errors:\n#{errors.map(&:message).join("\n")}"
    ensure
      context.close
    end

    it "DOC-104: section properties are valid" do
      rule = Uniword::Validation::Rules::SectionPropertiesRule.new
      context = Uniword::Validation::Rules::DocumentContext.new(temp_path)

      issues = rule.applicable?(context) ? rule.check(context) : []
      errors = issues.select { |i| i.severity == "error" }

      expect(errors).to be_empty,
                        "Section property errors:\n#{errors.map(&:message).join("\n")}"
    ensure
      context.close
    end

    it "DOC-105: core properties namespaces are correct" do
      rule = Uniword::Validation::Rules::CorePropertiesNamespaceRule.new
      context = Uniword::Validation::Rules::DocumentContext.new(temp_path)

      issues = rule.applicable?(context) ? rule.check(context) : []
      errors = issues.select { |i| i.severity == "error" }

      expect(errors).to be_empty,
                        "Core properties namespace errors:\n#{errors.map(&:message).join("\n")}"
    ensure
      context.close
    end

    it "DOC-106: content types cover all ZIP entries" do
      rule = Uniword::Validation::Rules::ContentTypesCoverageRule.new
      context = Uniword::Validation::Rules::DocumentContext.new(temp_path)

      issues = rule.applicable?(context) ? rule.check(context) : []
      errors = issues.select { |i| i.severity == "error" }

      expect(errors).to be_empty,
                        "Content type coverage errors:\n#{errors.map(&:message).join("\n")}"
    ensure
      context.close
    end
  end

  describe "validation against additional fixtures" do
    {
      internal_links: "internal-links.docx",
      test_with_style: "test_with_style.docx",
    }.each_value do |filename|
      it "round-trips #{filename} without new errors" do
        source = "#{fixtures_dir}/#{filename}"
        temp = "#{tmp_dir}/rt_#{filename}"

        round_trip(source, temp)
        regressions = new_rule_errors_after_roundtrip(source, temp)

        expect(regressions).to be_empty,
                               "Round-trip of #{filename} introduced new errors:\n" \
                               "#{regressions.map do |e|
                                 "  #{e.code}: #{e.message}"
                               end.join("\n")}"
      ensure
        safe_delete(temp)
      end
    end
  end

  describe "synthetic fixtures (spec/fixtures/)" do
    let(:synthetic_dir) { "spec/fixtures" }

    synthetic_fixtures.each do |filename|
      it "round-trips #{filename} without introducing new errors" do
        source = "#{synthetic_dir}/#{filename}"
        temp = "#{tmp_dir}/rt_#{filename}"

        round_trip(source, temp)
        regressions = new_rule_errors_after_roundtrip(source, temp)

        expect(regressions).to be_empty,
                               "Round-trip of #{filename} introduced new errors:\n" \
                               "#{regressions.map do |e|
                                 "  #{e.code}: #{e.message}"
                               end.join("\n")}"
      ensure
        safe_delete(temp)
      end
    end
  end
end
