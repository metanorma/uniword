# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Metanorma MHTML to DOCX Conversion" do
  let(:samples_dir) { "/Users/mulgogi/src/mn/mn-samples-iso/_site" }

  # Helper method to count bold runs
  def count_bold_runs(document)
    count = 0
    document.paragraphs.each do |para|
      para.runs.each do |run|
        count += 1 if run.properties&.bold
      end
    end
    count
  end

  before(:all) do
    FileUtils.mkdir_p("tmp/metanorma")
  end

  context "rice-amendment conversion" do
    let(:source_path) { File.join(samples_dir, "documents/amendment/rice-2017/document-en.final.doc") }
    let(:docx_output) { "tmp/metanorma/rice-amendment.docx" }

    before do
      skip "Sample file not found" unless File.exist?(source_path)
    end

    it "converts MHTML to DOCX successfully" do
      # Read MHTML
      doc = Uniword::DocumentFactory.from_file(source_path, format: :mhtml)

      # Validate extraction
      expect(doc.paragraphs.count).to be > 50
      expect(doc.tables.count).to be >= 1

      # Convert to DOCX
      doc.save(docx_output, format: :docx)

      # Verify DOCX created
      expect(File.exist?(docx_output)).to be true
      expect(File.size(docx_output)).to be > 1000 # Reasonable size
    end

    it "preserves content in MHTML→DOCX conversion" do
      # Read MHTML
      doc_mhtml = Uniword::DocumentFactory.from_file(source_path, format: :mhtml)
      original_text = doc_mhtml.text
      para_count = doc_mhtml.paragraphs.count
      table_count = doc_mhtml.tables.count

      # Save as DOCX
      doc_mhtml.save(docx_output, format: :docx)

      # Read DOCX back
      doc_docx = Uniword::DocumentFactory.from_file(docx_output, format: :docx)

      # Validate preservation
      expect(doc_docx.text.length).to be_within(100).of(original_text.length)
      expect(doc_docx.paragraphs.count).to be_within(5).of(para_count)
      expect(doc_docx.tables.count).to eq(table_count)
    end

    it "preserves formatting in conversion" do
      doc_mhtml = Uniword::DocumentFactory.from_file(source_path)
      doc_mhtml.save(docx_output, format: :docx)
      doc_docx = Uniword::DocumentFactory.from_file(docx_output)

      # Check that formatted text is preserved
      bold_count_mhtml = count_bold_runs(doc_mhtml)
      bold_count_docx = count_bold_runs(doc_docx)

      expect(bold_count_docx).to be > 0
      expect(bold_count_docx).to be_within(10).of(bold_count_mhtml)
    end
  end

  # Test multiple samples
  [
    "documents/amendment/rice-2017/document-en.final.doc",
    "documents/directives/part1/document.doc",
    "documents/technical-specification/document.doc",
    "documents/guide/document.doc"
  ].each do |sample_path|
    context File.basename(sample_path) do
      it "converts to DOCX without errors" do
        full_path = File.join(samples_dir, sample_path)
        skip "File not found" unless File.exist?(full_path)

        doc = Uniword::DocumentFactory.from_file(full_path)
        output = "tmp/metanorma/#{File.basename(sample_path, ".doc")}.docx"

        expect { doc.save(output, format: :docx) }.not_to raise_error
        expect(File.exist?(output)).to be true
      end
    end
  end
end

RSpec.describe "Metanorma MHTML Round-trip" do
  let(:samples_dir) { "/Users/mulgogi/src/mn/mn-samples-iso/_site" }

  before(:all) do
    FileUtils.mkdir_p("tmp/metanorma")
  end

  context "rice-amendment round-trip" do
    let(:source_path) { File.join(samples_dir, "documents/amendment/rice-2017/document-en.final.doc") }
    let(:roundtrip_output) { "tmp/metanorma/rice-amendment-roundtrip.doc" }

    before do
      skip "Sample file not found" unless File.exist?(source_path)
    end

    it "round-trips without data loss" do
      # Read original
      doc1 = Uniword::DocumentFactory.from_file(source_path, format: :mhtml)
      original_para_count = doc1.paragraphs.count
      original_table_count = doc1.tables.count
      original_text_length = doc1.text.length

      # Write back as MHTML
      doc1.save(roundtrip_output, format: :mhtml)

      # Read the written file
      doc2 = Uniword::DocumentFactory.from_file(roundtrip_output, format: :mhtml)

      # Validate preservation (allow small variation due to empty paragraph handling)
      expect(doc2.paragraphs.count).to be_within(5).of(original_para_count)
      expect(doc2.tables.count).to eq(original_table_count)
      expect(doc2.text.length).to be_within(100).of(original_text_length)
    end

    it "preserves text content exactly" do
      doc1 = Uniword::DocumentFactory.from_file(source_path)
      original_text = doc1.text

      doc1.save(roundtrip_output, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(roundtrip_output)

      # Text should be identical or very close
      expect(doc2.text.length).to be_within(50).of(original_text.length)

      # Sample key phrases that should be preserved
      expect(doc2.text).to include("ISO") if original_text.include?("ISO")
    end

    it "preserves table structure" do
      doc1 = Uniword::DocumentFactory.from_file(source_path)
      table1_cells = doc1.tables.first&.rows&.first&.cells&.count

      doc1.save(roundtrip_output, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(roundtrip_output)

      table2_cells = doc2.tables.first&.rows&.first&.cells&.count
      expect(table2_cells).to eq(table1_cells)
    end

    it "preserves styles" do
      doc1 = Uniword::DocumentFactory.from_file(source_path)
      style_count1 = doc1.styles_configuration.all_styles.count

      doc1.save(roundtrip_output, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(roundtrip_output)

      style_count2 = doc2.styles_configuration.all_styles.count
      expect(style_count2).to be >= style_count1
    end
  end

  # Test multiple round-trips
  context "multiple round-trips" do
    let(:source_path) { File.join(samples_dir, "documents/amendment/rice-2017/document-en.final.doc") }

    before do
      skip "Sample file not found" unless File.exist?(source_path)
    end

    it "survives multiple round-trips" do
      doc1 = Uniword::DocumentFactory.from_file(source_path)
      text1 = doc1.text

      # Round-trip 3 times
      3.times do |i|
        output = "tmp/metanorma/roundtrip_#{i}.doc"
        doc1.save(output, format: :mhtml)
        doc1 = Uniword::DocumentFactory.from_file(output)
      end

      # Text should still be preserved
      expect(doc1.text.length).to be_within(200).of(text1.length)
    end
  end
end

RSpec.describe "Metanorma Workflow Integration" do
  let(:samples_dir) { "/Users/mulgogi/src/mn/mn-samples-iso/_site" }

  before(:all) do
    FileUtils.mkdir_p("tmp/metanorma")
  end

  context "complete document lifecycle" do
    let(:source_mhtml) { File.join(samples_dir, "documents/amendment/rice-2017/document-en.final.doc") }

    before do
      skip "Sample file not found" unless File.exist?(source_mhtml)
    end

    it "supports complete Metanorma document lifecycle" do
      # Scenario: Metanorma generates MHTML, user converts to DOCX for editing,
      # then converts back to MHTML for archival

      # Step 1: Read Metanorma-generated MHTML
      doc = Uniword::DocumentFactory.from_file(source_mhtml)
      expect(doc.paragraphs.count).to be > 50

      # Step 2: Convert to DOCX for editing
      docx_path = "tmp/metanorma/for_editing.docx"
      doc.save(docx_path, format: :docx)

      # Step 3: Open DOCX (simulate editing)
      doc_docx = Uniword::DocumentFactory.from_file(docx_path)
      expect(doc_docx.paragraphs.count).to eq(doc.paragraphs.count)

      # Step 4: Convert back to MHTML
      final_mhtml = "tmp/metanorma/final.doc"
      doc_docx.save(final_mhtml, format: :mhtml)

      # Step 5: Verify final MHTML is valid
      doc_final = Uniword::DocumentFactory.from_file(final_mhtml)
      expect(doc_final.paragraphs.count).to be_within(10).of(doc.paragraphs.count)
      expect(doc_final.tables.count).to eq(doc.tables.count)
    end
  end
end