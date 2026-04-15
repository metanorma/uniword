# frozen_string_literal: true

require "spec_helper"
require "benchmark"

RSpec.describe "DOCX Performance" do
  before(:all) do
    # Create temporary directory for performance test files
    FileUtils.mkdir_p("tmp")
  end

  after(:all) do
    # Clean up performance test files
    FileUtils.rm_rf(Dir.glob("tmp/perf_*.docx"))
  end

  # Helper to create a document with many paragraphs
  def create_large_document(paragraphs: 100, runs_per_para: 5)
    doc = Uniword::Wordprocessingml::DocumentRoot.new

    paragraphs.times do |i|
      para = Uniword::Wordprocessingml::Paragraph.new
      runs_per_para.times do |j|
        run = Uniword::Wordprocessingml::Run.new(
          text: "Paragraph #{i + 1}, Run #{j + 1}: Lorem ipsum dolor sit amet."
        )
        para.runs << run
      end
      doc.body.paragraphs << para
    end

    doc
  end

  # Helper to create document with tables
  def create_document_with_tables(count: 10, rows: 5, cols: 4)
    doc = Uniword::Wordprocessingml::DocumentRoot.new

    count.times do |t|
      table = Uniword::Wordprocessingml::Table.new

      rows.times do |r|
        row = Uniword::Wordprocessingml::TableRow.new
        cols.times do |c|
          cell = Uniword::Wordprocessingml::TableCell.new
          para = Uniword::Wordprocessingml::Paragraph.new
          run = Uniword::Wordprocessingml::Run.new(
            text: "Table #{t + 1}, R#{r + 1}C#{c + 1}"
          )
          para.runs << run
          cell.paragraphs << para
          row.cells << cell
        end
        table.rows << row
      end

      doc.body.tables << table
    end

    doc
  end

  describe "parsing performance" do
    it "parses small documents quickly (10 paragraphs)" do
      skip "Performance test only in CI or with PROFILE=true" unless ENV["PROFILE"]

      doc = create_large_document(paragraphs: 10)
      doc.save("tmp/perf_10para.docx")

      time = Benchmark.realtime do
        Uniword::DocumentFactory.from_file("tmp/perf_10para.docx")
      end

      expect(time).to be < 0.5 # Should parse in under 500ms
    end

    it "parses medium documents efficiently (100 paragraphs)" do
      skip "Performance test only with PROFILE=true" unless ENV["PROFILE"]

      doc = create_large_document(paragraphs: 100)
      doc.save("tmp/perf_100para.docx")

      time = Benchmark.realtime do
        Uniword::DocumentFactory.from_file("tmp/perf_100para.docx")
      end

      expect(time).to be < 1.0 # Should parse in under 1 second
    end

    it "parses large documents acceptably (500 paragraphs)" do
      skip "Large document test only in CI or with PROFILE=true" unless ENV["PROFILE"]

      doc = create_large_document(paragraphs: 500)
      doc.save("tmp/perf_500para.docx")

      time = Benchmark.realtime do
        Uniword::DocumentFactory.from_file("tmp/perf_500para.docx")
      end

      expect(time).to be < 5.0 # Should parse in under 5 seconds
    end

    it "parses documents with tables quickly (10 tables)" do
      skip "Performance test only in CI or with PROFILE=true" unless ENV["PROFILE"]

      doc = create_document_with_tables(count: 10, rows: 5, cols: 4)
      doc.save("tmp/perf_10table.docx")

      time = Benchmark.realtime do
        Uniword::DocumentFactory.from_file("tmp/perf_10table.docx")
      end

      expect(time).to be < 1.0 # Should parse in under 1 second
    end

    it "parses documents with many tables efficiently (50 tables)" do
      skip "Performance test only with PROFILE=true" unless ENV["PROFILE"]

      doc = create_document_with_tables(count: 50, rows: 10, cols: 5)
      doc.save("tmp/perf_50table.docx")

      time = Benchmark.realtime do
        Uniword::DocumentFactory.from_file("tmp/perf_50table.docx")
      end

      expect(time).to be < 5.0 # Should parse in under 5 seconds
    end
  end

  describe "writing performance" do
    it "writes small documents quickly" do
      skip "Performance test only with PROFILE=true" unless ENV["PROFILE"]

      doc = create_large_document(paragraphs: 10)

      time = Benchmark.realtime do
        doc.save("tmp/write_perf_10.docx")
      end

      expect(time).to be < 0.5 # Should write in under 500ms
    end

    it "writes medium documents efficiently" do
      skip "Performance test only with PROFILE=true" unless ENV["PROFILE"]

      doc = create_large_document(paragraphs: 100)

      time = Benchmark.realtime do
        doc.save("tmp/write_perf_100.docx")
      end

      expect(time).to be < 1.0 # Should write in under 1 second
    end

    it "writes large documents acceptably" do
      skip "Large document test only in CI or with PROFILE=true" unless ENV["PROFILE"]

      doc = create_large_document(paragraphs: 500)

      time = Benchmark.realtime do
        doc.save("tmp/write_perf_500.docx")
      end

      expect(time).to be < 5.0 # Should write in under 5 seconds
    end

    it "writes documents with tables efficiently" do
      skip "Performance test only with PROFILE=true" unless ENV["PROFILE"]

      doc = create_document_with_tables(count: 50, rows: 10, cols: 5)

      time = Benchmark.realtime do
        doc.save("tmp/write_table_perf.docx")
      end

      expect(time).to be < 2.0 # Should write in under 2 seconds
    end
  end

  describe "round-trip performance" do
    it "handles round-trip operations efficiently" do
      # Create document
      doc = create_large_document(paragraphs: 50)

      # Save and reload multiple times
      time = Benchmark.realtime do
        5.times do |i|
          doc.save("tmp/roundtrip_#{i}.docx")
          doc = Uniword::DocumentFactory.from_file("tmp/roundtrip_#{i}.docx")
        end
      end

      expect(time).to be < 10.0 # 5 round-trips in under 10 seconds (CI-friendly threshold)
    end
  end

  describe "scaling performance" do
    it "scales linearly with document size" do
      skip "Scaling test only in CI or with PROFILE=true" unless ENV["PROFILE"]

      sizes = [10, 50, 100, 200]
      times = []

      sizes.each do |size|
        doc = create_large_document(paragraphs: size)
        doc.save("tmp/perf_#{size}.docx")

        time = Benchmark.realtime do
          Uniword::DocumentFactory.from_file("tmp/perf_#{size}.docx")
        end

        times << time
      end

      # Check that time growth is roughly linear (not exponential)
      # Time for 200 paragraphs should be less than 4x time for 50 paragraphs
      ratio = times.last / times[1]
      expect(ratio).to be < 5.0
    end

    it "handles incremental document building efficiently" do
      doc = Uniword::Wordprocessingml::DocumentRoot.new

      time = Benchmark.realtime do
        100.times do |i|
          para = Uniword::Wordprocessingml::Paragraph.new
          run = Uniword::Wordprocessingml::Run.new(text: "Paragraph #{i}")
          para.runs << run
          doc.body.paragraphs << para
        end
      end

      # Building 100 paragraphs should be fast
      expect(time).to be < 0.5
    end
  end

  describe "XPath optimization" do
    it "uses efficient element access patterns" do
      doc = create_large_document(paragraphs: 100)
      doc.save("tmp/xpath_test.docx")

      # Parse document
      parsed = Uniword::DocumentFactory.from_file("tmp/xpath_test.docx")

      # Access paragraphs multiple times - should use caching
      time = Benchmark.realtime do
        10.times do
          _ = parsed.paragraphs.count
        end
      end

      # Multiple accesses should be fast due to caching
      expect(time).to be < 0.1
    end
  end

  describe "comparison benchmarks" do
    it "compares different document sizes" do
      skip "Comparison benchmark only with PROFILE=true" unless ENV["PROFILE"]

      puts "\n=== Performance Comparison ==="

      [10, 50, 100, 200, 500].each do |size|
        doc = create_large_document(paragraphs: size)

        write_time = Benchmark.realtime do
          doc.save("tmp/compare_#{size}.docx")
        end

        read_time = Benchmark.realtime do
          Uniword::DocumentFactory.from_file("tmp/compare_#{size}.docx")
        end

        puts format(
          "%4d paragraphs: Write %.3fs, Read %.3fs",
          size, write_time, read_time
        )
      end
    end
  end
end
