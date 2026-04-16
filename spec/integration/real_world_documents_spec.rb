# frozen_string_literal: true

require "spec_helper"
require "benchmark"
require "benchmark/memory"
require "tmpdir"

RSpec.describe "Real-World Document Testing", :integration do
  # Integration tests using actual production documents
  # These tests validate that uniword can handle real-world complexity
  # and meet performance requirements for production use

  describe "Complex Document" do
    let(:doc_path) { "spec/fixtures/docx_gem/styles.docx" }

    describe "Document Reading" do
      it "opens complex document successfully" do
        doc = Uniword.load(doc_path)

        expect(doc).to be_a(Uniword::Wordprocessingml::DocumentRoot)
        expect(doc.paragraphs.count).to be > 0
        expect(doc.tables.count).to be >= 0
      end

      it "extracts all text content" do
        doc = Uniword.load(doc_path)
        text = doc.text

        expect(text).not_to be_empty
        expect(text.length).to be > 0
      end

      it "preserves document structure" do
        doc = Uniword.load(doc_path)

        expect(doc.styles_configuration).not_to be_nil
        expect(doc.numbering_configuration).not_to be_nil
        expect(doc.styles_configuration.styles.count).to be > 0
      end

      it "handles tables correctly" do
        doc = Uniword.load(doc_path)
        tables = doc.tables

        unless tables.empty?
          first_table = tables.first
          expect(first_table.rows).not_to be_empty
          expect(first_table.column_count).to be > 0
        end
      end

      it "preserves formatting properties" do
        doc = Uniword.load(doc_path)

        formatted_paras = doc.paragraphs.select do |p|
          p.properties && (p.properties.alignment || p.properties.style)
        end

        expect(formatted_paras).not_to be_empty
      end
    end

    describe "Round-Trip Preservation" do
      it "preserves content through write-read cycle" do
        original = Uniword.load(doc_path)
        original_text = original.text
        original_para_count = original.paragraphs.count

        temp_path = File.join(Dir.tmpdir, "roundtrip_#{Time.now.to_i}.docx")

        begin
          original.save(temp_path)
          roundtrip = Uniword.load(temp_path)

          expect(roundtrip.text).to eq(original_text)
          expect(roundtrip.paragraphs.count).to eq(original_para_count)
        ensure
          safe_rm_f(temp_path)
        end
      end

      it "preserves structure through round-trip" do
        original = Uniword.load(doc_path)

        temp_path = File.join(Dir.tmpdir, "structure_#{Time.now.to_i}.docx")

        begin
          original.save(temp_path)
          roundtrip = Uniword.load(temp_path)

          expect(roundtrip.tables.count).to eq(original.tables.count)
        ensure
          safe_rm_f(temp_path)
        end
      end

      it "preserves styles through round-trip" do
        original = Uniword.load(doc_path)
        original_style_count = original.styles_configuration.styles.count

        temp_path = File.join(Dir.tmpdir, "styles_#{Time.now.to_i}.docx")

        begin
          original.save(temp_path)
          roundtrip = Uniword.load(temp_path)

          expect(roundtrip.styles_configuration).not_to be_nil
          expect(roundtrip.styles_configuration.styles.count).to eq(original_style_count)
        ensure
          safe_rm_f(temp_path)
        end
      end
    end

    describe "Performance Benchmarks" do
      it "reads document in under 6 seconds" do
        read_time = Benchmark.realtime do
          Uniword.load(doc_path)
        end

        expect(read_time).to be < 6.0
      end

      it "writes document in under 10 seconds" do
        doc = Uniword.load(doc_path)
        temp_path = File.join(Dir.tmpdir, "perf_#{Time.now.to_i}.docx")

        write_time = Benchmark.realtime do
          doc.save(temp_path)
        end

        expect(write_time).to be < 10.0

        safe_rm_f(temp_path)
      end

      it "handles document without memory issues" do
        report = Benchmark.memory(quiet: true) do |x|
          x.report("load+text") { doc = Uniword.load(doc_path); doc.text }
        end

        entry = report.entries.first
        allocated_mb = entry.measurement.memory.allocated / 1024.0 / 1024.0
        retained_mb = entry.measurement.memory.retained / 1024.0 / 1024.0

        expect(allocated_mb).to be < 100,
                                 "Allocated #{allocated_mb.round(1)} MB, expected < 100 MB"
        expect(retained_mb).to be < 50,
                                "Retained #{retained_mb.round(1)} MB, expected < 50 MB"
      end

      it "provides responsive text extraction" do
        doc = Uniword.load(doc_path)

        extraction_time = Benchmark.realtime do
          10.times { doc.text }
        end

        avg_time = extraction_time / 10
        expect(avg_time).to be < 0.1
      end
    end

    describe "Error Resilience" do
      it "handles corrupted elements gracefully" do
        doc = Uniword.load(doc_path)

        expect { doc.paragraphs.each(&:text) }.not_to raise_error
        expect { doc.tables.each(&:row_count) }.not_to raise_error
      end

      it "provides meaningful error messages" do
        expect do
          Uniword.load("/nonexistent/file.docx")
        end.to raise_error(Uniword::FileNotFoundError, /not found/)
      end
    end
  end

  describe "Multiple Document Types" do
    let(:blank_path) { "spec/fixtures/blank/blank.docx" }

    it "handles simple documents efficiently" do
      skip "blank.docx fixture not available" unless File.exist?(blank_path)

      doc = Uniword.load(blank_path)
      expect(doc).to be_a(Uniword::Wordprocessingml::DocumentRoot)

      # Simple document should have minimal content
      expect(doc.paragraphs.count).to be >= 0

      # Round-trip should preserve structure
      temp_path = File.join(Dir.tmpdir, "simple_#{Time.now.to_i}.docx")
      begin
        doc.save(temp_path)
        roundtrip = Uniword.load(temp_path)
        expect(roundtrip.paragraphs.count).to eq(doc.paragraphs.count)
      ensure
        safe_rm_f(temp_path)
      end
    end

    it "handles documents with heavy formatting" do
      formatting_path = "spec/fixtures/docx_gem/formatting.docx"
      skip "formatting.docx fixture not available" unless File.exist?(formatting_path)

      doc = Uniword.load(formatting_path)
      expect(doc).to be_a(Uniword::Wordprocessingml::DocumentRoot)
      expect(doc.paragraphs.count).to be > 0

      # Verify formatting is preserved through round-trip
      temp_path = File.join(Dir.tmpdir, "formatting_#{Time.now.to_i}.docx")
      begin
        original_text = doc.text
        doc.save(temp_path)
        roundtrip = Uniword.load(temp_path)
        expect(roundtrip.text).to eq(original_text)
      ensure
        safe_rm_f(temp_path)
      end
    end

    it "handles documents with many tables" do
      tables_path = "spec/fixtures/docx_gem/tables.docx"
      skip "tables.docx fixture not available" unless File.exist?(tables_path)

      doc = Uniword.load(tables_path)
      expect(doc).to be_a(Uniword::Wordprocessingml::DocumentRoot)
      expect(doc.tables.count).to be > 0

      # Verify table structure through round-trip
      temp_path = File.join(Dir.tmpdir, "tables_#{Time.now.to_i}.docx")
      begin
        original_table_count = doc.tables.count
        doc.save(temp_path)
        roundtrip = Uniword.load(temp_path)
        expect(roundtrip.tables.count).to eq(original_table_count)
      ensure
        safe_rm_f(temp_path)
      end
    end

    it "handles documents with embedded images" do
      image_path = "spec/fixtures/uniword-demo/demo_formal_integral_proper.docx"
      skip "demo fixture not available" unless File.exist?(image_path)

      doc = Uniword.load(image_path)
      expect(doc).to be_a(Uniword::Wordprocessingml::DocumentRoot)
      expect(doc.paragraphs.count).to be > 0

      # Verify image is preserved through round-trip
      temp_path = File.join(Dir.tmpdir, "images_#{Time.now.to_i}.docx")
      begin
        doc.save(temp_path)
        Uniword.load(temp_path)

        # Image should be preserved in the package
        require "zip"
        original_has_image = Zip::File.open(image_path) { |z| z.find_entry("word/media/image1.jpeg") }
        roundtrip_has_image = Zip::File.open(temp_path) { |z| z.find_entry("word/media/image1.jpeg") }
        expect(roundtrip_has_image).not_to be_nil if original_has_image
      ensure
        safe_rm_f(temp_path)
      end
    end
  end

  describe "Concurrent Access" do
    let(:fixture_path) { "spec/fixtures/docx_gem/styles.docx" }

    it "supports thread-safe reading" do
      skip "styles.docx fixture not available" unless File.exist?(fixture_path)

      doc = Uniword.load(fixture_path)
      results = []
      mutex = Mutex.new

      threads = 10.times.map do
        Thread.new do
          text = doc.text
          count = doc.paragraphs.count
          mutex.synchronize { results << { text_length: text.length, para_count: count } }
        end
      end

      threads.each(&:join)

      # All threads should get consistent results
      expect(results.count).to eq(10)
      text_lengths = results.map { |r| r[:text_length] }
      para_counts = results.map { |r| r[:para_count] }
      expect(text_lengths.uniq).to eq([text_lengths.first])
      expect(para_counts.uniq).to eq([para_counts.first])
    end

    it "handles multiple documents simultaneously" do
      skip "styles.docx fixture not available" unless File.exist?(fixture_path)

      results = []
      mutex = Mutex.new

      threads = 5.times.map do
        Thread.new do
          doc = Uniword.load(fixture_path)
          text_len = doc.text.length
          para_count = doc.paragraphs.count
          mutex.synchronize { results << { text_length: text_len, para_count: para_count } }
        end
      end

      threads.each(&:join)

      # Each thread should independently load and read successfully
      expect(results.count).to eq(5)
      results.each do |r|
        expect(r[:text_length]).to be > 0
        expect(r[:para_count]).to be >= 0
      end
    end
  end

  describe "Edge Cases" do
    it "handles empty documents" do
      doc = Uniword::Wordprocessingml::DocumentRoot.new

      expect(doc.paragraphs).to be_empty
      expect(doc.tables).to be_empty
      expect(doc.text).to eq("")
    end

    it "handles very long paragraphs" do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: "x" * 100_000) # 100k characters
      para.runs << run

      doc.body.paragraphs << para
    end

    it "handles documents with unusual characters" do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: "Unicode: 你好世界 emoji: 🎉 math: ∑∫√")
      para.runs << run

      doc.body.paragraphs << para

      expect(doc.text).to include("你好世界")
      expect(doc.text).to include("🎉")
    end
  end

  describe "Production Readiness Checklist" do
    it "validates all critical functionality works" do
      checklist = {
        "Document creation" => -> { Uniword::Wordprocessingml::DocumentRoot.new },
        "Document opening" => lambda {
          Uniword.load("spec/fixtures/docx_gem/styles.docx")
        },
        "Paragraph creation" => -> { Uniword::Wordprocessingml::Paragraph.new },
        "Text addition" => lambda {
          p = Uniword::Wordprocessingml::Paragraph.new
          run = Uniword::Wordprocessingml::Run.new(text: "test")
          p.runs << run
        },
        "Table creation" => -> { Uniword::Wordprocessingml::Table.new },
        "Document saving" => lambda {
          doc = Uniword::Wordprocessingml::DocumentRoot.new
          para = Uniword::Wordprocessingml::Paragraph.new
          run = Uniword::Wordprocessingml::Run.new(text: "test")
          para.runs << run
          doc.body.paragraphs << para
          path = File.join(Dir.tmpdir, "test_#{Time.now.to_i}.docx")
          doc.save(path)
          safe_rm_f(path)
        }
      }

      failures = []
      checklist.each do |name, test|
        test.call
      rescue StandardError => e
        failures << "#{name}: #{e.message}"
      end

      expect(failures).to be_empty, "Failed checks: #{failures.join(", ")}"
    end
  end
end
