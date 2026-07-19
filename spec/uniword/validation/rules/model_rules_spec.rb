# frozen_string_literal: true

require "spec_helper"

# Model-level validation rules: the in-memory front-end of the
# validation engine (Rules::ModelContext over a DocumentRoot).
RSpec.describe Uniword::Validation::Rules::ModelRule do
  def issues_for(rule, document)
    context = Uniword::Validation::Rules::ModelContext.new(document)
    rule.check(context)
  end

  def document_with_body
    Uniword::Wordprocessingml::DocumentRoot.new
  end

  def document_with_table(table)
    document_with_body.tap { |doc| doc.body.tables << table }
  end

  def bookmark_start(id, name)
    Uniword::Wordprocessingml::BookmarkStart.new(id: id, name: name)
  end

  describe Uniword::Validation::Rules::DocumentBodyRule do
    let(:rule) { described_class.new }

    let(:bodiless_document) do
      document_with_body.tap { |doc| doc.body = nil }
    end

    it "has code DOC-200" do
      expect(rule.code).to eq("DOC-200")
    end

    it "is a model-level rule" do
      expect(rule.context_type).to eq(:model)
    end

    it "passes when the document has a body" do
      expect(issues_for(rule, document_with_body)).to be_empty
    end

    it "fails when the body is missing" do
      messages = issues_for(rule, bodiless_document).map(&:message)
      expect(messages).to include("Document body is missing")
    end
  end

  describe Uniword::Validation::Rules::BookmarkPairingRule do
    let(:rule) { described_class.new }

    let(:paired_document) do
      document_with_body.tap do |doc|
        doc.body.bookmark_starts << bookmark_start("1", "a")
        doc.body.bookmark_ends <<
          Uniword::Wordprocessingml::BookmarkEnd.new(id: "1")
      end
    end

    let(:unpaired_document) do
      document_with_body.tap do |doc|
        doc.body.bookmark_starts << bookmark_start("42", "x")
      end
    end

    it "has code DOC-201" do
      expect(rule.code).to eq("DOC-201")
    end

    it "passes for paired bookmarks" do
      expect(issues_for(rule, paired_document)).to be_empty
    end

    it "flags the unpaired bookmarkStart id" do
      messages = issues_for(rule, unpaired_document).map(&:message)
      expect(messages.first).to include("id='42'")
    end

    it "reports unpaired bookmarks as errors" do
      expect(issues_for(rule, unpaired_document).first.severity)
        .to eq("error")
    end
  end

  describe Uniword::Validation::Rules::BookmarkUniquenessRule do
    let(:rule) { described_class.new }

    let(:duplicate_document) do
      document_with_body.tap do |doc|
        doc.body.bookmark_starts << bookmark_start("1", "dup")
        doc.body.bookmark_starts << bookmark_start("2", "dup")
      end
    end

    let(:go_back_document) do
      document_with_body.tap do |doc|
        doc.body.bookmark_starts << bookmark_start("1", "_GoBack")
        doc.body.bookmark_starts << bookmark_start("2", "_GoBack")
      end
    end

    it "has code DOC-202" do
      expect(rule.code).to eq("DOC-202")
    end

    it "flags the duplicated bookmark name" do
      messages = issues_for(rule, duplicate_document).map(&:message)
      expect(messages).to include("Duplicate bookmark name 'dup'")
    end

    it "reports duplicates as warnings" do
      expect(issues_for(rule, duplicate_document).first.severity)
        .to eq("warning")
    end

    it "ignores the Word-internal _GoBack bookmark" do
      expect(issues_for(rule, go_back_document)).to be_empty
    end
  end

  describe Uniword::Validation::Rules::EmptyParagraphsRule do
    let(:rule) { described_class.new }

    let(:empty_para_document) do
      document_with_body.tap do |doc|
        doc.body.paragraphs << Uniword::Wordprocessingml::Paragraph.new
      end
    end

    let(:filled_document) do
      run = Uniword::Wordprocessingml::Run.new(text: "text")
      para = Uniword::Wordprocessingml::Paragraph.new(runs: [run])
      document_with_body.tap { |doc| doc.body.paragraphs << para }
    end

    it "has code DOC-203" do
      expect(rule.code).to eq("DOC-203")
    end

    it "warns on empty paragraphs" do
      messages = issues_for(rule, empty_para_document).map(&:message)
      expect(messages).to include("Empty paragraph at index 0")
    end

    it "passes for paragraphs with runs" do
      expect(issues_for(rule, filled_document)).to be_empty
    end
  end

  describe Uniword::Validation::Rules::TableGridRule do
    let(:rule) { described_class.new }

    let(:gridless_document) do
      document_with_table(Uniword::Wordprocessingml::Table.new)
    end

    let(:gridded_document) do
      table = Uniword::Wordprocessingml::Table.new(
        grid: Uniword::Wordprocessingml::TableGrid.new,
      )
      document_with_table(table)
    end

    it "has code DOC-204" do
      expect(rule.code).to eq("DOC-204")
    end

    it "flags a table without tblGrid" do
      messages = issues_for(rule, gridless_document).map(&:message)
      expect(messages.first).to include("tblGrid")
    end

    it "reports a missing tblGrid as an error" do
      expect(issues_for(rule, gridless_document).first.severity)
        .to eq("error")
    end

    it "passes for a table with tblGrid" do
      expect(issues_for(rule, gridded_document)).to be_empty
    end
  end

  describe Uniword::Validation::Rules::TablePropertiesRule do
    let(:rule) { described_class.new }

    let(:propless_document) do
      document_with_table(Uniword::Wordprocessingml::Table.new)
    end

    let(:propertied_document) do
      table = Uniword::Wordprocessingml::Table.new(
        properties: Uniword::Wordprocessingml::TableProperties.new,
      )
      document_with_table(table)
    end

    it "has code DOC-205" do
      expect(rule.code).to eq("DOC-205")
    end

    it "flags a table without tblPr" do
      messages = issues_for(rule, propless_document).map(&:message)
      expect(messages.first).to include("tblPr")
    end

    it "passes for a table with tblPr" do
      expect(issues_for(rule, propertied_document)).to be_empty
    end
  end

  describe "DocumentRoot integration" do
    let(:document_with_bad_table) do
      document_with_table(Uniword::Wordprocessingml::Table.new)
    end

    it "is invalid with a table missing tblGrid" do
      expect(document_with_bad_table.valid?).to be false
    end

    it "is valid for a minimal clean document" do
      expect(document_with_body.valid?).to be true
    end

    it "reports tblGrid via #validation_errors" do
      expect(document_with_bad_table.validation_errors).to include(
        "Table 1 is missing the required tblGrid element",
      )
    end

    it "reports empty paragraphs via #validation_warnings" do
      document = document_with_body
      document.body.paragraphs << Uniword::Wordprocessingml::Paragraph.new
      warnings = document.validation_warnings
      expect(warnings).to include("Empty paragraph at index 0")
    end
  end
end
