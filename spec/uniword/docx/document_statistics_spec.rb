# frozen_string_literal: true

require "spec_helper"
require "uniword/docx"

RSpec.describe Uniword::Docx::DocumentStatistics do
  def build_package(*paragraph_texts)
    package = Uniword::Docx::Package.new
    package.document = Uniword::Wordprocessingml::DocumentRoot.new

    paragraph_texts.each do |text|
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new
      run.text = text
      para.runs << run
      package.document.body.paragraphs << para
    end

    package
  end

  def build_package_with_table(texts_grid)
    package = Uniword::Docx::Package.new
    package.document = Uniword::Wordprocessingml::DocumentRoot.new
    table = Uniword::Wordprocessingml::Table.new

    texts_grid.each do |row_texts|
      row = Uniword::Wordprocessingml::TableRow.new
      row_texts.each do |text|
        cell = Uniword::Wordprocessingml::TableCell.new
        para = Uniword::Wordprocessingml::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new
        run.text = text
        para.runs << run
        cell.paragraphs << para
        row.cells << cell
      end
      table.rows << row
    end

    package.document.body.tables << table
    package
  end

  describe "empty document" do
    it "returns minimal stats" do
      package = Uniword::Docx::Package.new
      package.document = Uniword::Wordprocessingml::DocumentRoot.new

      stats = described_class.new(package).calculate

      expect(stats[:pages]).to eq(1)
      expect(stats[:words]).to eq(0)
      expect(stats[:characters]).to eq(0)
      expect(stats[:characters_with_spaces]).to eq(0)
      expect(stats[:paragraphs]).to eq(0)
      expect(stats[:lines]).to eq(1)
    end
  end

  describe "no document" do
    it "returns minimal stats" do
      package = Uniword::Docx::Package.new

      stats = described_class.new(package).calculate

      expect(stats[:words]).to eq(0)
      expect(stats[:characters]).to eq(0)
    end
  end

  # All values verified against Microsoft Word 2024
  describe "simple text" do
    it "counts a single word correctly" do
      stats = described_class.new(build_package("Hello")).calculate

      # Word 2024: W=1 C=5 CWS=5 P=1 L=1
      expect(stats[:words]).to eq(1)
      expect(stats[:characters]).to eq(5)
      expect(stats[:characters_with_spaces]).to eq(5)
      expect(stats[:paragraphs]).to eq(1)
      expect(stats[:lines]).to eq(1)
    end

    it "counts words with spaces" do
      stats = described_class.new(build_package("Hello World")).calculate

      # Word 2024: W=2 C=10 CWS=11 P=1 L=1
      expect(stats[:words]).to eq(2)
      expect(stats[:characters]).to eq(10)
      expect(stats[:characters_with_spaces]).to eq(11)
      expect(stats[:paragraphs]).to eq(1)
      expect(stats[:lines]).to eq(1)
    end

    it "counts multiple paragraphs" do
      stats = described_class.new(build_package("Hello", "World")).calculate

      # Word 2024: W=2 C=10 CWS=10 P=2 L=2
      expect(stats[:words]).to eq(2)
      expect(stats[:characters]).to eq(10)
      expect(stats[:characters_with_spaces]).to eq(10)
      expect(stats[:paragraphs]).to eq(2)
      expect(stats[:lines]).to eq(2)
    end
  end

  describe "CJK text" do
    it "counts each CJK character as a word" do
      stats = described_class.new(build_package("你好")).calculate

      # 2 CJK chars = 2 words
      expect(stats[:words]).to eq(2)
    end

    it "counts mixed CJK and Latin text" do
      stats = described_class.new(build_package("Hello 你好 World 世界")).calculate

      # Word 2024: W=6 C=14 CWS=17 P=1 L=1
      # Hello(1) + 你(1) + 好(1) + World(1) + 世(1) + 界(1) = 6 words
      expect(stats[:words]).to eq(6)
      expect(stats[:characters]).to eq(14)
      expect(stats[:characters_with_spaces]).to eq(17)
    end
  end

  describe "empty paragraphs" do
    it "excludes empty paragraphs from paragraph count" do
      package = build_package("Hello", "", "World")
      stats = described_class.new(package).calculate

      # Word 2024: W=2 C=10 CWS=10 P=2 L=2 (empty para excluded)
      expect(stats[:paragraphs]).to eq(2)
      expect(stats[:words]).to eq(2)
      expect(stats[:characters]).to eq(10)
      expect(stats[:lines]).to eq(2)
    end
  end

  describe "tables" do
    it "counts table cell paragraphs" do
      package = build_package_with_table([
                                           ["Cell1", "Cell2"],
                                           ["Cell3", "Cell4"],
                                         ])

      stats = described_class.new(package).calculate

      # 4 non-empty paragraphs (one per cell), 4 words
      expect(stats[:paragraphs]).to eq(4)
      expect(stats[:words]).to eq(4)
    end

    it "counts characters in table cells" do
      package = build_package_with_table([["AB", "CD"]])

      stats = described_class.new(package).calculate

      # "AB" (2) + "CD" (2) = 4 chars, 0 spaces
      expect(stats[:characters]).to eq(4)
      expect(stats[:characters_with_spaces]).to eq(4)
    end
  end

  describe "pages and lines" do
    it "returns at least 1 page" do
      stats = described_class.new(build_package("Hello")).calculate

      expect(stats[:pages]).to eq(1)
    end

    it "returns at least 1 line" do
      stats = described_class.new(build_package("Hello")).calculate

      expect(stats[:lines]).to eq(1)
    end

    it "approximates pages for many paragraphs" do
      texts = Array.new(50) { "Text" }
      stats = described_class.new(build_package(*texts)).calculate

      expect(stats[:pages]).to be >= 2
    end
  end

  describe "longer text (verified against Word 2024)" do
    it "matches Word statistics for multi-paragraph document" do
      stats = described_class.new(build_package(
                                    "The quick brown fox jumps over the lazy dog.",
                                    "This is a second paragraph with more text.",
                                  )).calculate

      # Word 2024: W=17 C=71 CWS=86 P=2 L=2
      expect(stats[:words]).to eq(17)
      expect(stats[:characters]).to eq(71)
      expect(stats[:characters_with_spaces]).to eq(86)
      expect(stats[:paragraphs]).to eq(2)
      expect(stats[:lines]).to eq(2)
    end
  end

  describe "integration with reconciler" do
    let(:profile) { Uniword::Docx::Profile.load(:word_2024_en) }

    it "populates app.xml statistics from document content" do
      package = Uniword::Docx::Package.new
      package.document = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new
      run.text = "Hello World"
      para.runs << run
      package.document.body.paragraphs << para

      Uniword::Docx::Reconciler.new(package, profile: profile).reconcile

      app = package.app_properties
      # Word 2024: W=2 C=10 CWS=11 P=1
      expect(app.words).to eq("2")
      expect(app.characters).to eq("10")
      expect(app.characters_with_spaces).to eq("11")
      expect(app.paragraphs).to eq("1")
    end
  end
end
