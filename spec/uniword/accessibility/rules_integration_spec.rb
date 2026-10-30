# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Accessibility Rules Integration" do
  let(:document) { Uniword::Wordprocessingml::DocumentRoot.new }

  def document_from_body(body)
    Uniword::Wordprocessingml::DocumentRoot.from_xml(<<~XML)
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:body>#{body}</w:body></w:document>
    XML
  end

  def heading(style)
    %(<w:p><w:pPr><w:pStyle w:val="#{style}"/></w:pPr>) +
      "<w:r><w:t>H</w:t></w:r></w:p>"
  end

  def table_xml
    "<w:tbl><w:tr><w:tc><w:p><w:r><w:t>cell</w:t></w:r></w:p></w:tc>" \
      "</w:tr></w:tbl>"
  end

  # A picture whose wp:docPr carries no descr, so it has no alt text.
  def document_with_alt_less_picture
    Uniword::Wordprocessingml::DocumentRoot.from_xml(<<~XML)
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <w:document
        xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
        xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing">
        <w:body><w:p><w:r><w:drawing><wp:inline>
          <wp:docPr id="1" name="Picture 1"/>
        </wp:inline></w:drawing></w:r></w:p></w:body>
      </w:document>
    XML
  end

  describe "All rules can be instantiated" do
    let(:config) do
      {
        wcag_criterion: "Test",
        level: "A",
        enabled: true,
        severity: :error,
      }
    end

    it "ImageAltTextRule" do
      rule = Uniword::Accessibility::Rules::ImageAltTextRule.new(config)
      expect(rule).to be_a(Uniword::Accessibility::AccessibilityRule)
      expect(rule.check(document)).to be_an(Array)
    end

    it "HeadingStructureRule" do
      rule = Uniword::Accessibility::Rules::HeadingStructureRule.new(config)
      expect(rule).to be_a(Uniword::Accessibility::AccessibilityRule)
      expect(rule.check(document)).to be_an(Array)
    end

    it "TableHeadersRule" do
      rule = Uniword::Accessibility::Rules::TableHeadersRule.new(config)
      expect(rule).to be_a(Uniword::Accessibility::AccessibilityRule)
      expect(rule.check(document)).to be_an(Array)
    end

    it "ListStructureRule" do
      rule = Uniword::Accessibility::Rules::ListStructureRule.new(config)
      expect(rule).to be_a(Uniword::Accessibility::AccessibilityRule)
      expect(rule.check(document)).to be_an(Array)
    end

    it "ReadingOrderRule" do
      rule = Uniword::Accessibility::Rules::ReadingOrderRule.new(config)
      expect(rule).to be_a(Uniword::Accessibility::AccessibilityRule)
      expect(rule.check(document)).to be_an(Array)
    end

    it "ColorUsageRule" do
      rule = Uniword::Accessibility::Rules::ColorUsageRule.new(config)
      expect(rule).to be_a(Uniword::Accessibility::AccessibilityRule)
      expect(rule.check(document)).to be_an(Array)
    end

    it "ContrastRatioRule" do
      rule = Uniword::Accessibility::Rules::ContrastRatioRule.new(config)
      expect(rule).to be_a(Uniword::Accessibility::AccessibilityRule)
      expect(rule.check(document)).to be_an(Array)
    end

    it "DocumentTitleRule" do
      rule = Uniword::Accessibility::Rules::DocumentTitleRule.new(config)
      expect(rule).to be_a(Uniword::Accessibility::AccessibilityRule)
      expect(rule.check(document)).to be_an(Array)
    end

    it "DescriptiveHeadingsRule" do
      rule = Uniword::Accessibility::Rules::DescriptiveHeadingsRule.new(config)
      expect(rule).to be_a(Uniword::Accessibility::AccessibilityRule)
      expect(rule.check(document)).to be_an(Array)
    end

    it "LanguageSpecificationRule" do
      rule = Uniword::Accessibility::Rules::LanguageSpecificationRule.new(config)
      expect(rule).to be_a(Uniword::Accessibility::AccessibilityRule)
      expect(rule.check(document)).to be_an(Array)
    end
  end

  describe "Rules return violations when issues found" do
    it "ImageAltTextRule detects missing alt text" do
      document = document_with_alt_less_picture

      rule = Uniword::Accessibility::Rules::ImageAltTextRule.new(
        wcag_criterion: "1.1.1",
        level: "A",
        severity: :error,
      )
      violations = rule.check(document)

      expect(violations).not_to be_empty
      expect(violations.first).to be_a(Uniword::Accessibility::AccessibilityViolation)
    end

    it "TableHeadersRule detects missing headers" do
      document = document_from_body(table_xml)

      rule = Uniword::Accessibility::Rules::TableHeadersRule.new(
        wcag_criterion: "1.3.1",
        level: "A",
        severity: :error,
      )
      violations = rule.check(document)

      expect(violations.map(&:message)).to eq(["Table 1 missing header row"])
    end

    it "TableHeadersRule accepts a flagged header row" do
      document = document_from_body(table_xml)
      document.tables.first.rows.first.header = true

      rule = Uniword::Accessibility::Rules::TableHeadersRule.new(
        wcag_criterion: "1.3.1",
        level: "A",
        severity: :error,
      )

      expect(rule.check(document)).to be_empty
    end

    it "HeadingStructureRule detects hierarchy skips" do
      document = document_from_body(heading("Heading1") + heading("Heading3"))

      rule = Uniword::Accessibility::Rules::HeadingStructureRule.new(
        wcag_criterion: "1.3.1",
        level: "A",
        check_hierarchy: true,
        no_level_skipping: true,
        severity: :error,
      )
      violations = rule.check(document)

      expect(violations.size).to eq(1)
      expect(violations.first.message).to include("hierarchy skip")
    end

    it "HeadingStructureRule accepts consecutive heading levels" do
      document = document_from_body(heading("Heading1") + heading("Heading2"))

      rule = Uniword::Accessibility::Rules::HeadingStructureRule.new(
        wcag_criterion: "1.3.1",
        level: "A",
        check_hierarchy: true,
        no_level_skipping: true,
        severity: :error,
      )

      expect(rule.check(document)).to be_empty
    end
  end

  describe "Rules respect enabled flag" do
    def checker_with_image_rule(enabled:)
      config = Tempfile.new(["rules_integration", ".yml"])
      File.write(config.path, {
        profiles: {
          single: {
            name: "Single", level: "Test",
            rules: { image_alt_text: { enabled: enabled,
                                       wcag_criterion: "1.1.1",
                                       level: "A" } }
          },
        },
      }.to_yaml)
      Uniword::Accessibility::AccessibilityChecker.new(
        profile: :single, config_file: config.path,
      )
    ensure
      config&.close!
    end

    it "disabled rules return no violations" do
      document = document_with_alt_less_picture

      enabled = checker_with_image_rule(enabled: true).check(document)
      disabled = checker_with_image_rule(enabled: false).check(document)

      expect(enabled.violations.map(&:message))
        .to eq(["Image 1 missing alternative text"])
      expect(disabled.violations).to be_empty
    end
  end
end
