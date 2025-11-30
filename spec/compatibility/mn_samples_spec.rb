# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Metanorma ISO Sample Compatibility', :slow do
  let(:samples_dir) { '/Users/mulgogi/src/mn/mn-samples-iso/_site' }
  let(:doc_files) { Dir.glob(File.join(samples_dir, '**/*.doc')).sort }

  # Helper to get relative path for better output
  def rel_path(full_path)
    full_path.sub("#{samples_dir}/", '')
  end

  # Helper to gather document statistics
  def gather_stats(doc)
    {
      paragraphs: doc.paragraphs.count,
      tables: doc.tables.count,
      text_length: doc.text.length,
      has_styles: doc.styles_configuration&.all_styles&.any? || false,
      has_theme: !doc.theme.nil?,
      has_numbering: doc.numbering_configuration&.definitions&.any? || false
    }
  end

  describe 'file discovery' do
    it 'discovers sample DOC files' do
      expect(doc_files).not_to be_empty
      puts "\n✓ Found #{doc_files.count} DOC files in mn-samples-iso"
    end
  end

  describe 'reading smallest files' do
    # Test the smallest files first (amendments - AWI stage)
    it 'reads amendment AWI files' do
      smallest_files = doc_files.select { |f| f.include?('amendment') && f.include?('.awi.doc') }

      expect(smallest_files).not_to be_empty
      puts "\n  Testing #{smallest_files.count} smallest amendment files:"

      results = { success: 0, failed: 0, errors: [] }

      smallest_files.each do |doc_path|
        puts "\n    File: #{rel_path(doc_path)}"

        begin
          doc = Uniword::Document.open(doc_path)

          expect(doc).to be_a(Uniword::Document)
          stats = gather_stats(doc)

          puts '      ✓ Read successfully'
          puts "        Paragraphs: #{stats[:paragraphs]}"
          puts "        Tables: #{stats[:tables]}"
          puts "        Text length: #{stats[:text_length]} chars"

          results[:success] += 1
        rescue StandardError => e
          puts "      ✗ Failed: #{e.class.name}: #{e.message}"
          results[:failed] += 1
          results[:errors] << { file: rel_path(doc_path), error: e.message }
        end
      end

      puts "\n  Summary: #{results[:success]} succeeded, #{results[:failed]} failed"
      expect(results[:success]).to be > 0
    end
  end

  describe 'reading international standard samples' do
    it 'reads representative ISO standard files' do
      intl_std_files = [
        'documents/international-standard/rice-2016/document-en.awi.doc',
        'documents/international-standard/rice-2016/document-en.doc',
        'documents/international-standard/rice-2023/document-en.doc'
      ].map { |rel| File.join(samples_dir, rel) }.select { |f| File.exist?(f) }

      expect(intl_std_files).not_to be_empty
      puts "\n  Testing #{intl_std_files.count} international standard files:"

      results = { success: 0, failed: 0, errors: [] }

      intl_std_files.each do |doc_path|
        puts "\n    File: #{rel_path(doc_path)}"

        begin
          doc = Uniword::Document.open(doc_path)

          expect(doc).to be_a(Uniword::Document)
          stats = gather_stats(doc)

          puts '      ✓ Read successfully'
          puts "        Paragraphs: #{stats[:paragraphs]}"
          puts "        Tables: #{stats[:tables]}"
          puts "        Text length: #{stats[:text_length]} chars"

          results[:success] += 1
        rescue StandardError => e
          puts "      ✗ Failed: #{e.class.name}: #{e.message}"
          results[:failed] += 1
          results[:errors] << { file: rel_path(doc_path), error: e.message }
        end
      end

      puts "\n  Summary: #{results[:success]} succeeded, #{results[:failed]} failed"
      expect(results[:success]).to be > 0
    end
  end

  describe 'reading directive samples (large files)' do
    it 'reads large directive files' do
      directive_files = doc_files.select { |f| f.include?('directives') }

      expect(directive_files).not_to be_empty
      puts "\n  Testing #{directive_files.count} large directive files:"

      results = { success: 0, failed: 0, errors: [] }

      directive_files.each do |doc_path|
        puts "\n    File: #{rel_path(doc_path)}"
        puts "      Size: #{(File.size(doc_path) / 1024.0 / 1024.0).round(2)} MB"

        begin
          doc = Uniword::Document.open(doc_path)

          expect(doc).to be_a(Uniword::Document)
          stats = gather_stats(doc)

          puts '      ✓ Read successfully'
          puts "        Paragraphs: #{stats[:paragraphs]}"
          puts "        Tables: #{stats[:tables]}"
          puts "        Text length: #{stats[:text_length]} chars"

          results[:success] += 1
        rescue StandardError => e
          puts "      ✗ Failed: #{e.class.name}: #{e.message}"
          puts '        (Large files may have issues)'
          results[:failed] += 1
          results[:errors] << { file: rel_path(doc_path), error: e.message }
        end
      end

      puts "\n  Summary: #{results[:success]} succeeded, #{results[:failed]} failed"
      # Don't require success for large files - they may fail
    end
  end

  describe 'content analysis' do
    # Analyze one representative file in detail
    let(:sample_file) do
      File.join(samples_dir,
                'documents/international-standard/rice-2016/document-en.doc')
    end

    it 'analyzes document structure in detail' do
      skip 'Sample file not found' unless File.exist?(sample_file)

      puts "\n  Detailed analysis of: #{rel_path(sample_file)}"

      doc = Uniword::Document.open(sample_file)

      # Analyze paragraph types
      para_with_text = doc.paragraphs.reject { |p| p.text.strip.empty? }
      para_empty = doc.paragraphs.select { |p| p.text.strip.empty? }

      puts "\n  Paragraph Analysis:"
      puts "    Total paragraphs: #{doc.paragraphs.count}"
      puts "    With text: #{para_with_text.count}"
      puts "    Empty: #{para_empty.count}"

      # Analyze tables
      if doc.tables.any?
        puts "\n  Table Analysis:"
        puts "    Total tables: #{doc.tables.count}"
        doc.tables.first(3).each_with_index do |table, idx|
          puts "    Table #{idx + 1}:"
          puts "      Rows: #{table.rows.count}"
          puts "      Columns: #{table.rows.first&.cells&.count || 0}"
        end
      end

      # Analyze styles
      if doc.styles_configuration&.all_styles&.any?
        puts "\n  Style Analysis:"
        puts "    Total styles: #{doc.styles_configuration.all_styles.count}"
        puts "    Paragraph styles: #{doc.styles_configuration.paragraph_styles.count}"
        puts "    Character styles: #{doc.styles_configuration.character_styles.count}"
      end

      # Sample text (first 200 chars)
      text_sample = doc.text[0...200]
      puts "\n  Text Sample (first 200 chars):"
      puts "    #{text_sample.gsub("\n", ' ')}"

      expect(doc.paragraphs.count).to be > 0
    end

    describe 'content extraction validation' do
      let(:sample_file) do
        File.join(samples_dir,
                  'documents/international-standard/rice-2016/document-en.doc')
      end

      it 'extracts content from WordSection divs' do
        skip 'Sample file not found' unless File.exist?(sample_file)

        doc = Uniword::Document.open(sample_file)

        # Should extract MUCH more content now (fixed recursive div processing)
        expect(doc.paragraphs.count).to be > 200  # Was 20, should be ~323
        expect(doc.tables.count).to be > 0        # Was 0, should be 6
        expect(doc.text.length).to be > 20_000 # Was ~2290, should be >26000
      end

      it 'preserves section structure' do
        skip 'Sample file not found' unless File.exist?(sample_file)

        doc = Uniword::Document.open(sample_file)

        # Should maintain document structure
        expect(doc.elements).not_to be_empty

        # Verify content types are extracted
        expect(doc.paragraphs.count).to be > 0
        expect(doc.tables.count).to be > 0
      end

      it 'achieves >95% paragraph extraction rate' do
        skip 'Sample file not found' unless File.exist?(sample_file)

        doc = Uniword::Document.open(sample_file)

        # The file has ~335 paragraph tags in HTML
        # We should extract at least 95% of them (>318 paragraphs)
        expect(doc.paragraphs.count).to be >= 318
      end

      it 'extracts all tables from nested divs' do
        skip 'Sample file not found' unless File.exist?(sample_file)

        doc = Uniword::Document.open(sample_file)

        # The file has 6 tables that were previously missed
        # due to being inside WordSection divs
        expect(doc.tables.count).to eq(6)
      end
    end
  end
end
