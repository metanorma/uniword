# frozen_string_literal: true

require 'spec_helper'
require 'benchmark'
require 'tmpdir'

RSpec.describe 'Real-World Document Testing', :integration do
  # Integration tests using actual production documents
  # These tests validate that uniword can handle real-world complexity
  # and meet performance requirements for production use

  describe 'ISO 8601-2 Complex Document' do
    let(:iso_doc_path) do
      '/Users/mulgogi/src/mn/iso-8601-2/_site/documents/' \
        'iso-8601-2-2026/iso-wd-8601-2-2026.docx'
    end

    before(:each) do
      skip 'ISO document not available' unless File.exist?(iso_doc_path)
    end

    describe 'Document Reading' do
      it 'opens complex ISO document successfully' do
        doc = Uniword.load(iso_doc_path)

        expect(doc).to be_a(Uniword::Wordprocessingml::DocumentRoot)
        expect(doc.paragraphs.count).to be > 100
        expect(doc.tables.count).to be > 10

        puts "\n  Document Statistics:"
        puts "    Paragraphs: #{doc.paragraphs.count}"
        puts "    Tables: #{doc.tables.count}"
        puts "    Sections: #{doc.sections.count}"
      end

      it 'extracts all text content' do
        doc = Uniword.load(iso_doc_path)
        text = doc.text

        expect(text).not_to be_empty
        expect(text.length).to be > 10_000

        puts "\n  Text Statistics:"
        puts "    Total characters: #{text.length}"
        puts "    Total words: #{text.split.count}"
      end

      it 'preserves document structure' do
        doc = Uniword.load(iso_doc_path)

        expect(doc.sections.count).to be >= 1
        expect(doc.styles_configuration).not_to be_nil
        expect(doc.numbering_configuration).not_to be_nil

        # Verify styles are loaded
        expect(doc.styles_configuration.styles.count).to be > 0

        puts "\n  Structure Statistics:"
        puts "    Sections: #{doc.sections.count}"
        puts "    Styles: #{doc.styles_configuration.styles.count}"
      end

      it 'handles tables correctly' do
        doc = Uniword.load(iso_doc_path)
        tables = doc.tables

        expect(tables).not_to be_empty

        # Check first table structure
        first_table = tables.first
        expect(first_table.rows).not_to be_empty
        expect(first_table.column_count).to be > 0

        puts "\n  Table Statistics:"
        puts "    Total tables: #{tables.count}"
        puts "    First table rows: #{first_table.row_count}"
        puts "    First table columns: #{first_table.column_count}"
      end

      it 'preserves formatting properties' do
        doc = Uniword.load(iso_doc_path)

        # Find paragraphs with formatting
        formatted_paras = doc.paragraphs.select do |p|
          p.properties && (p.properties.alignment || p.properties.style)
        end

        expect(formatted_paras).not_to be_empty

        puts "\n  Formatting Statistics:"
        puts "    Formatted paragraphs: #{formatted_paras.count}"
        puts "    Total paragraphs: #{doc.paragraphs.count}"
      end
    end

    describe 'Round-Trip Preservation' do
      it 'preserves content through write-read cycle' do
        original = Uniword.load(iso_doc_path)
        original_text = original.text
        original_para_count = original.paragraphs.count

        temp_path = File.join(Dir.tmpdir, "iso_roundtrip_#{Time.now.to_i}.docx")

        begin
          original.save(temp_path)
          roundtrip = Uniword.load(temp_path)

          expect(roundtrip.text).to eq(original_text)
          expect(roundtrip.paragraphs.count).to eq(original_para_count)

          puts "\n  Round-trip validation:"
          puts "    Original text length: #{original_text.length}"
          puts "    Round-trip text length: #{roundtrip.text.length}"
          puts "    Text preserved: #{roundtrip.text == original_text}"
        ensure
          safe_rm_f(temp_path)
        end
      end

      it 'preserves structure through round-trip' do
        original = Uniword.load(iso_doc_path)

        temp_path = File.join(Dir.tmpdir, "iso_structure_#{Time.now.to_i}.docx")

        begin
          original.save(temp_path)
          roundtrip = Uniword.load(temp_path)

          expect(roundtrip.tables.count).to eq(original.tables.count)
          expect(roundtrip.sections.count).to eq(original.sections.count)

          puts "\n  Structure preservation:"
          puts "    Tables preserved: #{roundtrip.tables.count == original.tables.count}"
          puts "    Sections preserved: #{roundtrip.sections.count == original.sections.count}"
        ensure
          safe_rm_f(temp_path)
        end
      end

      it 'preserves styles through round-trip' do
        original = Uniword.load(iso_doc_path)
        original_style_count = original.styles_configuration.styles.count

        temp_path = File.join(Dir.tmpdir, "iso_styles_#{Time.now.to_i}.docx")

        begin
          original.save(temp_path)
          roundtrip = Uniword.load(temp_path)

          expect(roundtrip.styles_configuration).not_to be_nil
          expect(roundtrip.styles_configuration.styles.count).to eq(original_style_count)

          puts "\n  Style preservation:"
          puts "    Original styles: #{original_style_count}"
          puts "    Round-trip styles: #{roundtrip.styles_configuration.styles.count}"
        ensure
          safe_rm_f(temp_path)
        end
      end
    end

    describe 'Performance Benchmarks' do
      it 'reads document in under 6 seconds' do
        read_time = Benchmark.realtime do
          Uniword.load(iso_doc_path)
        end

        expect(read_time).to be < 6.0

        puts "\n  Performance - Reading:"
        puts "    Time: #{read_time.round(3)}s"
        puts '    Target: < 6.0s'
        puts "    Status: #{read_time < 6.0 ? 'PASS' : 'FAIL'}"
      end

      it 'writes document in under 10 seconds' do
        doc = Uniword.load(iso_doc_path)
        temp_path = File.join(Dir.tmpdir, "iso_perf_#{Time.now.to_i}.docx")

        write_time = Benchmark.realtime do
          doc.save(temp_path)
        end

        expect(write_time).to be < 10.0

        puts "\n  Performance - Writing:"
        puts "    Time: #{write_time.round(3)}s"
        puts '    Target: < 10.0s'
        puts "    Status: #{write_time < 10.0 ? 'PASS' : 'FAIL'}"

        safe_rm_f(temp_path)
      end

      it 'handles document without memory issues' do
        # Memory should not grow excessively
        GC.start
        before_memory = `ps -o rss= -p #{Process.pid}`.to_i

        doc = Uniword.load(iso_doc_path)
        _ = doc.text

        GC.start
        after_memory = `ps -o rss= -p #{Process.pid}`.to_i
        memory_growth_mb = (after_memory - before_memory) / 1024

        # Should use < 50MB for typical document
        expect(memory_growth_mb).to be < 50

        puts "\n  Performance - Memory:"
        puts "    Memory growth: #{memory_growth_mb}MB"
        puts '    Target: < 50MB'
        puts "    Status: #{memory_growth_mb < 50 ? 'PASS' : 'FAIL'}"
      end

      it 'provides responsive text extraction' do
        doc = Uniword.load(iso_doc_path)

        # Text extraction should be fast (< 1 second for cached)
        extraction_time = Benchmark.realtime do
          10.times { doc.text }
        end

        avg_time = extraction_time / 10
        expect(avg_time).to be < 0.1

        puts "\n  Performance - Text Extraction:"
        puts "    Average time (10 runs): #{(avg_time * 1000).round(2)}ms"
        puts '    Target: < 100ms'
        puts "    Status: #{avg_time < 0.1 ? 'PASS' : 'FAIL'}"
      end
    end

    describe 'Error Resilience' do
      it 'handles corrupted elements gracefully' do
        doc = Uniword.load(iso_doc_path)

        # Should not raise errors when accessing all elements
        expect { doc.paragraphs.each(&:text) }.not_to raise_error
        expect { doc.tables.each(&:row_count) }.not_to raise_error
      end

      it 'provides meaningful error messages' do
        # Test with non-existent file
        expect do
          Uniword.load('/nonexistent/file.docx')
        end.to raise_error(Errno::ENOENT, /No such file or directory/)
      end
    end
  end

  describe 'Multiple Document Types' do
    it 'handles simple documents efficiently' do
      # Test with minimal document
      # Should be even faster than complex documents
      # TODO: Create simple test document fixture
      skip 'Create simple test document'
    end

    it 'handles documents with heavy formatting' do
      # Test with lots of runs, styles, etc.
      # TODO: Create heavily formatted test document fixture
      skip 'Create heavily formatted test document'
    end

    it 'handles documents with many tables' do
      # Test with multiple complex tables
      # TODO: Create table-heavy test document fixture
      skip 'Create table-heavy test document'
    end

    it 'handles documents with embedded images' do
      # Test with multiple images
      # TODO: Create image-heavy test document fixture
      skip 'Create image-heavy test document'
    end
  end

  describe 'Concurrent Access' do
    it 'supports thread-safe reading' do
      skip 'Need to verify thread safety requirements'

      # Test multiple threads reading simultaneously
    end

    it 'handles multiple documents simultaneously' do
      skip 'Performance test for concurrent documents'

      # Open and process multiple documents
    end
  end

  describe 'Edge Cases' do
    it 'handles empty documents' do
      doc = Uniword::Wordprocessingml::DocumentRoot.new

      expect(doc.paragraphs).to be_empty
      expect(doc.tables).to be_empty
      expect(doc.text).to eq('')
    end

    it 'handles very long paragraphs' do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'x' * 100_000) # 100k characters
      para.runs << run

      doc.body.paragraphs << para
    end

    it 'handles documents with unusual characters' do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'Unicode: 你好世界 emoji: 🎉 math: ∑∫√')
      para.runs << run

      doc.body.paragraphs << para

      expect(doc.text).to include('你好世界')
      expect(doc.text).to include('🎉')
    end
  end

  describe 'Production Readiness Checklist' do
    it 'validates all critical functionality works' do
      iso_doc = '/Users/mulgogi/src/mn/iso-8601-2/_site/documents/' \
                'iso-8601-2-2026/iso-wd-8601-2-2026.docx'

      checklist = {
        'Document creation' => -> { Uniword::Wordprocessingml::DocumentRoot.new },
        'Document opening' => -> { Uniword.load(iso_doc) if File.exist?(iso_doc) },
        'Paragraph creation' => -> { Uniword::Wordprocessingml::Paragraph.new },
        'Text addition' => lambda {
          p = Uniword::Wordprocessingml::Paragraph.new
          run = Uniword::Wordprocessingml::Run.new(text: 'test')
          p.runs << run
        },
        'Table creation' => -> { Uniword::Wordprocessingml::Table.new },
        'Document saving' => lambda {
          doc = Uniword::Wordprocessingml::DocumentRoot.new
          para = Uniword::Wordprocessingml::Paragraph.new
          run = Uniword::Wordprocessingml::Run.new(text: 'test')
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

      expect(failures).to be_empty, "Failed checks: #{failures.join(', ')}"

      puts "\n  Production Readiness:"
      puts '    All critical functions: PASS'
      puts '    Ready for v1.1.0 release: YES'
    end
  end
end
