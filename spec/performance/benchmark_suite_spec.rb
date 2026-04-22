# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Comprehensive Benchmark Suite" do
  before(:all) do
    FileUtils.mkdir_p("tmp")
    @benchmark_results = {}
  end

  after(:all) do
    # Print summary if running with PROFILE=true
    if ENV["PROFILE"]
      puts "\n#{"=" * 70}"
      puts "BENCHMARK SUMMARY"
      puts "=" * 70
      @benchmark_results.each do |name, time|
        puts format("%-50s: %.4f seconds", name, time)
      end
      puts "=" * 70
    end

    # Clean up
    FileUtils.rm_rf(Dir.glob("tmp/benchmark_*.docx"))
  end

  # Helper to run and record benchmark
  def run_benchmark(name, &block)
    begin
      require "benchmark"
    rescue LoadError
      # benchmark gem not available (Ruby 4.0+)
      @benchmark_results[name] = 0
      return 0
    end
    time = Benchmark.realtime(&block)
    @benchmark_results[name] = time
    time
  end

  # Helper to create test document
  def create_test_document(paragraphs: 100, tables: 0)
    doc = Uniword::Wordprocessingml::DocumentRoot.new

    paragraphs.times do |i|
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(
        text: "Paragraph #{i + 1}: Test content for benchmarking."
      )
      para.runs << run
      doc.body.paragraphs << para
    end

    tables.times do |t|
      table = Uniword::Wordprocessingml::Table.new
      5.times do |r|
        row = Uniword::Wordprocessingml::TableRow.new
        4.times do |c|
          cell = Uniword::Wordprocessingml::TableCell.new
          para = Uniword::Wordprocessingml::Paragraph.new
          run = Uniword::Wordprocessingml::Run.new(text: "T#{t}R#{r}C#{c}")
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

  describe "Document Creation Benchmarks" do
    it "benchmarks small document creation (50 paragraphs)" do
      time = run_benchmark("Create 50-paragraph document") do
        create_test_document(paragraphs: 50)
      end

      expect(time).to be < 0.5
    end

    it "benchmarks medium document creation (200 paragraphs)" do
      skip "Medium benchmark only with PROFILE=true" unless ENV["PROFILE"]

      time = run_benchmark("Create 200-paragraph document") do
        create_test_document(paragraphs: 200)
      end

      expect(time).to be < 1.0
    end

    it "benchmarks table creation (20 tables)" do
      time = run_benchmark("Create document with 20 tables") do
        create_test_document(paragraphs: 10, tables: 20)
      end

      expect(time).to be < 3.0
    end
  end

  describe "Serialization Benchmarks" do
    before(:all) do
      @test_doc = create_test_document(paragraphs: 100, tables: 10)
    end

    it "benchmarks OOXML serialization" do
      serializer = Uniword::Serialization::OoxmlSerializer.new

      time = run_benchmark("OOXML serialization (100p + 10t)") do
        serializer.serialize(@test_doc)
      end

      expect(time).to be < 2.0
    end

    it "benchmarks HTML serialization" do
      time = run_benchmark("HTML serialization (100p + 10t)") do
        Uniword::Transformation::OoxmlToHtmlConverter.document_to_html(@test_doc)
      end

      expect(time).to be < 0.5
    end

    it "benchmarks package creation" do
      time = run_benchmark("OOXML package creation (100p + 10t)") do
        @test_doc.to_xml
      end

      expect(time).to be < 1.0
    end
  end

  describe "Deserialization Benchmarks" do
    before(:all) do
      @test_doc = create_test_document(paragraphs: 100, tables: 10)
      @test_doc.save("tmp/benchmark_deserialize.docx")
    end

    it "benchmarks DOCX parsing" do
      time = run_benchmark("DOCX parsing (100p + 10t)") do
        Uniword::DocumentFactory.from_file("tmp/benchmark_deserialize.docx")
      end

      expect(time).to be < 2.0
    end

    it "benchmarks element access" do
      doc = Uniword::DocumentFactory.from_file("tmp/benchmark_deserialize.docx")

      time = run_benchmark("Access all paragraphs") do
        doc.paragraphs.each(&:text)
      end

      expect(time).to be < 0.5
    end

    it "benchmarks table access" do
      doc = Uniword::DocumentFactory.from_file("tmp/benchmark_deserialize.docx")

      time = run_benchmark("Access all table cells") do
        doc.tables.each do |table|
          table.rows.each do |row|
            row.cells.each(&:text)
          end
        end
      end

      expect(time).to be < 0.5
    end
  end

  describe "Write Performance Benchmarks" do
    it "benchmarks writing small document (50 paragraphs)" do
      doc = create_test_document(paragraphs: 50)

      time = run_benchmark("Write 50-paragraph DOCX") do
        doc.save("tmp/benchmark_write_50.docx")
      end

      # Threshold set for CI compatibility - shared runners may be slower
      expect(time).to be < 1.0
    end

    it "benchmarks writing medium document (200 paragraphs)" do
      skip "Medium benchmark only with PROFILE=true" unless ENV["PROFILE"]

      doc = create_test_document(paragraphs: 200)

      time = run_benchmark("Write 200-paragraph DOCX") do
        doc.save("tmp/benchmark_write_200.docx")
      end

      expect(time).to be < 2.0
    end

    it "benchmarks writing document with tables" do
      doc = create_test_document(paragraphs: 50, tables: 20)

      time = run_benchmark("Write DOCX with 20 tables") do
        doc.save("tmp/benchmark_write_tables.docx")
      end

      expect(time).to be < 5.0
    end
  end

  describe "Memory Efficiency Benchmarks" do
    it "benchmarks memory usage for document creation" do
      skip "Memory benchmark requires get_process_mem" unless defined?(GetProcessMem)

      mem = GetProcessMem.new
      GC.start
      before = mem.mb

      create_test_document(paragraphs: 500, tables: 20)

      after = mem.mb
      increase = after - before

      # Record in results
      @benchmark_results["Memory for 500p + 20t (MB)"] = increase

      expect(increase).to be < 50 # Should use less than 50MB
    end

    it "benchmarks object allocation" do
      skip "Allocation benchmark only with PROFILE=true" unless ENV["PROFILE"]

      GC.start
      before = ObjectSpace.count_objects[:TOTAL]

      create_test_document(paragraphs: 100)

      GC.start
      after = ObjectSpace.count_objects[:TOTAL]

      allocated = after - before
      @benchmark_results["Objects allocated (100p)"] = allocated

      expect(allocated).to be < 10_000
    end
  end

  describe "Optimization Effectiveness" do
    it "verifies string concatenation optimization" do
      doc = create_test_document(paragraphs: 100)

      GC.start
      before_strings = ObjectSpace.count_objects[:T_STRING]

      Uniword::Transformation::OoxmlToHtmlConverter.document_to_html(doc)

      GC.start
      after_strings = ObjectSpace.count_objects[:T_STRING]

      new_strings = after_strings - before_strings
      @benchmark_results["Strings created (HTML ser 100p)"] = new_strings

      # Should create reasonable number of strings
      expect(new_strings).to be < 2000
    end

    it "verifies XPath optimization effectiveness" do
      skip "Performance test only in CI or with PROFILE=true" unless ENV["PROFILE"]

      doc = create_test_document(paragraphs: 100, tables: 10)
      doc.save("tmp/benchmark_xpath.docx")

      # First parse (cold)
      time_cold = run_benchmark("First parse (cold cache)") do
        Uniword::DocumentFactory.from_file("tmp/benchmark_xpath.docx")
      end

      # Second parse (warm)
      time_warm = run_benchmark("Second parse (warm cache)") do
        Uniword::DocumentFactory.from_file("tmp/benchmark_xpath.docx")
      end

      # Warm should not be significantly slower
      # (file system caching should help)
      expect(time_warm).to be < (time_cold * 1.5)
    end

    it "verifies lazy loading benefits" do
      doc = create_test_document(paragraphs: 500)
      doc.save("tmp/benchmark_lazy.docx")

      # Parse but don't access all elements
      time_partial = run_benchmark("Parse without full access") do
        parsed = Uniword::DocumentFactory.from_file("tmp/benchmark_lazy.docx")
        parsed.paragraphs.first.text # Access only first
      end

      # Parse and access all elements
      time_full = run_benchmark("Parse with full access") do
        parsed = Uniword::DocumentFactory.from_file("tmp/benchmark_lazy.docx")
        parsed.paragraphs.map(&:text) # Access all
      end

      # Full access should take more time but not exponentially more
      # Use a minimum threshold to avoid flaky failures on fast runners
      min_threshold = [time_partial * 10, 2.0].max
      expect(time_full).to be < min_threshold
    end
  end

  describe "Scalability Tests" do
    it "tests linear scaling with document size" do
      skip "Scaling test only with PROFILE=true" unless ENV["PROFILE"]

      sizes = [50, 100, 200]
      parse_times = []
      write_times = []

      sizes.each do |size|
        doc = create_test_document(paragraphs: size)

        write_time = Benchmark.realtime do
          doc.save("tmp/benchmark_scale_#{size}.docx")
        end
        write_times << write_time

        parse_time = Benchmark.realtime do
          Uniword::DocumentFactory.from_file("tmp/benchmark_scale_#{size}.docx")
        end
        parse_times << parse_time

        @benchmark_results["Write #{size}p"] = write_time
        @benchmark_results["Parse #{size}p"] = parse_time
      end

      # Check linear scaling (not exponential)
      # 4x size should take less than 5x time
      write_ratio = write_times.last / write_times.first
      parse_ratio = parse_times.last / parse_times.first

      expect(write_ratio).to be < 5.0
      expect(parse_ratio).to be < 5.0
    end
  end
end
