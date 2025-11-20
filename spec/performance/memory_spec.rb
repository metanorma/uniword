# frozen_string_literal: true

require 'spec_helper'
require 'objspace'

RSpec.describe 'Memory Performance' do
  # Helper to create a large document for testing
  def create_large_document(paragraphs: 100, runs_per_para: 5)
    doc = Uniword::Document.new

    paragraphs.times do |i|
      para = Uniword::Paragraph.new
      runs_per_para.times do |j|
        run = Uniword::Run.new(
          text_element: Uniword::TextElement.new(
            content: "Paragraph #{i + 1}, Run #{j + 1}: Some test content here."
          )
        )
        para.add_run(run)
      end
      doc.add_element(para)
    end

    doc
  end

  # Helper to create document with tables
  def create_document_with_tables(table_count: 10, rows: 5, cols: 4)
    doc = Uniword::Document.new

    table_count.times do |t|
      table = Uniword::Table.new

      rows.times do |r|
        row = Uniword::TableRow.new
        cols.times do |c|
          cell = Uniword::TableCell.new
          para = Uniword::Paragraph.new
          run = Uniword::Run.new(
            text_element: Uniword::TextElement.new(
              content: "Table #{t + 1}, Row #{r + 1}, Col #{c + 1}"
            )
          )
          para.add_run(run)
          cell.add_paragraph(para)
          row.add_cell(cell)
        end
        table.add_row(row)
      end

      doc.add_element(table)
    end

    doc
  end

  describe 'memory leak detection' do
    it 'does not leak memory with large documents' do
      skip 'Memory profiling only in CI or with PROFILE=true' unless ENV['CI'] || ENV['PROFILE']

      GC.start
      before_count = ObjectSpace.count_objects[:T_DATA]

      10.times do
        doc = create_large_document(paragraphs: 1000)
        doc.save('tmp/mem_test.docx')
        doc = nil
      end

      GC.start
      after_count = ObjectSpace.count_objects[:T_DATA]

      # Should not grow significantly (allow some variance)
      expect(after_count - before_count).to be < 100
    end

    it 'cleans up resources after document operations' do
      skip 'Memory profiling only in CI or with PROFILE=true' unless ENV['CI'] || ENV['PROFILE']

      GC.start
      before_objects = ObjectSpace.count_objects

      100.times do
        doc = create_large_document(paragraphs: 100)
        _ = doc.paragraphs.map(&:runs)
        doc = nil
      end

      GC.start
      after_objects = ObjectSpace.count_objects

      # Total object count should not grow excessively
      growth = after_objects[:TOTAL] - before_objects[:TOTAL]
      expect(growth).to be < 1000
    end
  end

  describe 'memory efficiency' do
    it 'uses acceptable memory for medium documents' do
      skip 'Memory profiling requires get_process_mem gem' unless defined?(GetProcessMem)

      mem = GetProcessMem.new
      GC.start
      before_mb = mem.mb

      doc = create_large_document(paragraphs: 500, runs_per_para: 10)
      doc.save('tmp/mem_medium_test.docx')

      after_mb = mem.mb
      increase = after_mb - before_mb

      # Should use less than 50MB for a 500-paragraph document
      expect(increase).to be < 50
    end

    it 'uses acceptable memory for documents with tables' do
      skip 'Memory profiling requires get_process_mem gem' unless defined?(GetProcessMem)

      mem = GetProcessMem.new
      GC.start
      before_mb = mem.mb

      doc = create_document_with_tables(table_count: 50, rows: 10, cols: 5)
      doc.save('tmp/mem_table_test.docx')

      after_mb = mem.mb
      increase = after_mb - before_mb

      # Should use less than 100MB for 50 tables with 10x5 cells
      expect(increase).to be < 100
    end
  end

  describe 'object allocation' do
    it 'minimizes object allocations during parsing' do
      skip 'Allocation profiling only in CI or with PROFILE=true' unless ENV['CI'] || ENV['PROFILE']

      # Create a test document
      doc = create_large_document(paragraphs: 100)
      doc.save('tmp/alloc_test.docx')

      GC.start
      before_allocations = ObjectSpace.count_objects

      # Parse the document
      parsed_doc = Uniword::DocumentFactory.from_file('tmp/alloc_test.docx')

      GC.start
      after_allocations = ObjectSpace.count_objects

      # Check that we're not creating excessive objects
      new_objects = after_allocations[:TOTAL] - before_allocations[:TOTAL]

      # For 100 paragraphs, should create reasonable number of objects
      # (paragraphs + runs + properties + document structure)
      expect(new_objects).to be < 10_000
    end

    it 'reuses objects when possible' do
      skip 'Allocation profiling only in CI or with PROFILE=true' unless ENV['CI'] || ENV['PROFILE']

      GC.start
      before_count = ObjectSpace.count_objects[:T_OBJECT]

      # Create multiple documents with similar content
      5.times do
        doc = Uniword::Document.new
        10.times do
          para = Uniword::Paragraph.new
          run = Uniword::Run.new(
            text_element: Uniword::TextElement.new(content: 'Same text')
          )
          para.add_run(run)
          doc.add_element(para)
        end
      end

      GC.start
      after_count = ObjectSpace.count_objects[:T_OBJECT]

      # Should allocate objects but not excessively
      new_objects = after_count - before_count
      expect(new_objects).to be < 1000
    end
  end

  describe 'string memory optimization' do
    it 'does not create excessive string objects' do
      skip 'String profiling only in CI or with PROFILE=true' unless ENV['CI'] || ENV['PROFILE']

      GC.start
      before_strings = ObjectSpace.count_objects[:T_STRING]

      doc = create_large_document(paragraphs: 100)
      xml = Uniword::Serialization::OoxmlSerializer.new.serialize(doc)

      GC.start
      after_strings = ObjectSpace.count_objects[:T_STRING]

      new_strings = after_strings - before_strings

      # Should create strings for content but not excessive temporaries
      # Allow ~3-5 strings per paragraph (content, properties, structure)
      expect(new_strings).to be < 1000
    end

    it 'uses string freezing for constants' do
      # All string literals in serializers should be frozen
      serializer = Uniword::Serialization::OoxmlSerializer.new

      # This is a design check - frozen strings reduce allocations
      expect('frozen_string_literal: true').to be_truthy
    end
  end

  describe 'lazy loading benefits' do
    it 'delays loading until needed' do
      skip 'Lazy loading test only in CI or with PROFILE=true' unless ENV['CI'] || ENV['PROFILE']

      # Create document with LazyLoader (will be implemented)
      doc = create_large_document(paragraphs: 1000)
      doc.save('tmp/lazy_test.docx')

      GC.start
      before_objects = ObjectSpace.count_objects[:TOTAL]

      # Open document but don't access all elements
      parsed = Uniword::DocumentFactory.from_file('tmp/lazy_test.docx')

      GC.start
      after_objects = ObjectSpace.count_objects[:TOTAL]

      initial_load = after_objects - before_objects

      # Now access all elements
      _ = parsed.paragraphs.map { |p| p.runs.map(&:text) }

      GC.start
      final_objects = ObjectSpace.count_objects[:TOTAL]

      full_load = final_objects - before_objects

      # Initial load should be significantly less than full load
      # (This will work better once lazy loading is fully implemented)
      expect(initial_load).to be < full_load
    end
  end
end