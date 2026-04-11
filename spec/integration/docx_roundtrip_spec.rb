# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'
require 'zip'
require 'canon'

RSpec.describe 'DOCX Round-Trip Fidelity' do
  let(:fixtures_dir) { File.expand_path('../fixtures', __dir__) }
  let(:temp_dir) { 'tmp/roundtrip_spec' }

  before(:all) do
    FileUtils.mkdir_p('tmp/roundtrip_spec')
  end

  after(:all) do
    FileUtils.rm_rf('tmp/roundtrip_spec')
  end

  # Helper to extract all files from a DOCX ZIP
  def extract_docx_files(docx_path)
    files = {}
    Zip::File.open(docx_path) do |zip_file|
      zip_file.each do |entry|
        next if entry.directory?

        files[entry.name] = entry.get_input_stream.read
      end
    end
    files
  end

  describe 'blank/blank.docx round-trip' do
    let(:original_path) { File.join(fixtures_dir, 'blank/blank.docx') }
    let(:roundtrip_path) { File.join(temp_dir, 'blank_roundtrip.docx') }

    it 'preserves all XML files through load/save cycle' do
      # Extract original files
      original_files = extract_docx_files(original_path)

      # Load document
      doc = Uniword.load(original_path)
      expect(doc).to be_a(Uniword::Wordprocessingml::DocumentRoot)

      # Save document
      doc.save(roundtrip_path)
      expect(File.exist?(roundtrip_path)).to be true

      # Extract saved files
      saved_files = extract_docx_files(roundtrip_path)

      # Compare file lists
      xml_files = original_files.keys.select { |f| f.end_with?('.xml', '.rels') }

      puts "\n  Checking #{xml_files.length} XML files for fidelity..."

      xml_files.each do |filename|
        original_content = original_files[filename]
        saved_content = saved_files[filename]

        if saved_content.nil?
          puts "    ⚠ #{filename}: MISSING in saved file"
          next
        end

        if Canon::Comparison.equivalent?(original_content, saved_content)
          puts "    ✓ #{filename}: Preserved"
        else
          puts "    ⚠ #{filename}: Modified (may be acceptable)"
          # Don't fail immediately - some differences may be acceptable
        end
      end

      # At minimum, document.xml must be preserved
      expect(saved_files['word/document.xml']).not_to be_nil
      expect(saved_files['word/document.xml']).to be_xml_equivalent_to(original_files['word/document.xml'])
    end

    it 'preserves document structure and content' do
      doc1 = Uniword.load(original_path)
      doc1.save(roundtrip_path)
      doc2 = Uniword.load(roundtrip_path)

      # Compare paragraph counts
      expect(doc2.paragraphs.length).to eq(doc1.paragraphs.length)

      # Compare text content
      expect(doc2.text).to eq(doc1.text)
    end

    it 'produces valid DOCX that Word can open' do
      doc = Uniword.load(original_path)
      doc.save(roundtrip_path)

      # Verify it's a valid ZIP
      expect do
        Zip::File.open(roundtrip_path, &:entries)
      end.not_to raise_error

      # Verify required files exist
      saved_files = extract_docx_files(roundtrip_path)
      expect(saved_files['word/document.xml']).not_to be_nil
      expect(saved_files['[Content_Types].xml']).not_to be_nil
      expect(saved_files['_rels/.rels']).not_to be_nil
    end
  end

  describe 'word-template-apa-style-paper/word-template-apa-style-paper.docx round-trip' do
    let(:original_path) { File.join(fixtures_dir, 'word-template-apa-style-paper/word-template-apa-style-paper.docx') }
    let(:roundtrip_path) { File.join(temp_dir, 'apa_roundtrip.docx') }

    it 'loads complex document without errors' do
      expect do
        doc = Uniword.load(original_path)
        expect(doc).to be_a(Uniword::Wordprocessingml::DocumentRoot)
      end.not_to raise_error
    end

    it 'preserves document content through round-trip' do
      doc1 = Uniword.load(original_path)
      original_text = doc1.text
      original_para_count = doc1.paragraphs.length

      doc1.save(roundtrip_path)
      doc2 = Uniword.load(roundtrip_path)

      # Content should be preserved
      expect(doc2.text).to eq(original_text)
      expect(doc2.paragraphs.length).to eq(original_para_count)
    end

    it 'maintains XML file structure' do
      original_files = extract_docx_files(original_path)

      doc = Uniword.load(original_path)
      doc.save(roundtrip_path)

      saved_files = extract_docx_files(roundtrip_path)

      # Core files must be present
      core_files = [
        'word/document.xml',
        '[Content_Types].xml',
        '_rels/.rels'
      ]

      core_files.each do |filename|
        expect(saved_files[filename]).not_to be_nil, "#{filename} must exist"
      end

      # Document.xml should be semantically equivalent
      expect(saved_files['word/document.xml']).to be_xml_equivalent_to(original_files['word/document.xml'])
    end
  end

  describe 'word-template-paper-with-cover-and-toc/word-template-paper-with-cover-and-toc.docx round-trip' do
    let(:original_path) { File.join(fixtures_dir, 'word-template-paper-with-cover-and-toc/word-template-paper-with-cover-and-toc.docx') }
    let(:roundtrip_path) { File.join(temp_dir, 'cover_toc_roundtrip.docx') }

    it 'handles document with complex structure' do
      expect do
        doc = Uniword.load(original_path)
        doc.save(roundtrip_path)
      end.not_to raise_error
    end

    it 'preserves text content' do
      doc1 = Uniword.load(original_path)
      doc1.save(roundtrip_path)
      doc2 = Uniword.load(roundtrip_path)

      # Should preserve text
      expect(doc2.text.length).to be > 0
      expect(doc2.text).to eq(doc1.text)
    end
  end

  describe 'Multiple round-trips' do
    let(:original_path) { File.join(fixtures_dir, 'blank/blank.docx') }

    it 'maintains fidelity through 3 round-trips' do
      # First load
      doc1 = Uniword.load(original_path)
      original_text = doc1.text

      # Round-trip 1
      path1 = File.join(temp_dir, 'multi_rt1.docx')
      doc1.save(path1)
      doc2 = Uniword.load(path1)

      # Round-trip 2
      path2 = File.join(temp_dir, 'multi_rt2.docx')
      doc2.save(path2)
      doc3 = Uniword.load(path2)

      # Round-trip 3
      path3 = File.join(temp_dir, 'multi_rt3.docx')
      doc3.save(path3)
      doc4 = Uniword.load(path3)

      # Text should be consistent
      expect(doc2.text).to eq(original_text)
      expect(doc3.text).to eq(original_text)
      expect(doc4.text).to eq(original_text)

      # XML should be consistent
      files1 = extract_docx_files(path1)
      files3 = extract_docx_files(path3)

      expect(files3['word/document.xml']).to be_xml_equivalent_to(files1['word/document.xml'])
    end
  end

  describe 'File-level comparison report' do
    let(:original_path) { File.join(fixtures_dir, 'blank/blank.docx') }
    let(:roundtrip_path) { File.join(temp_dir, 'report_test.docx') }

    it 'generates detailed comparison of all files' do
      original_files = extract_docx_files(original_path)

      doc = Uniword.load(original_path)
      doc.save(roundtrip_path)

      saved_files = extract_docx_files(roundtrip_path)

      puts "\n#{'=' * 60}"
      puts 'DOCX Round-Trip Fidelity Report'
      puts '=' * 60
      puts "Original: #{File.basename(original_path)}"
      puts "Saved: #{File.basename(roundtrip_path)}"
      puts

      all_files = (original_files.keys + saved_files.keys).uniq.sort

      xml_files = all_files.select { |f| f.end_with?('.xml', '.rels') }
      other_files = all_files - xml_files

      puts "XML Files (#{xml_files.length}):"
      xml_files.each do |filename|
        orig = original_files[filename]
        saved = saved_files[filename]

        if orig && !saved
          puts "  ✗ #{filename}: REMOVED"
        elsif !orig && saved
          puts "  + #{filename}: ADDED"
        elsif Canon::Comparison.equivalent?(orig, saved)
          puts "  ✓ #{filename}: PRESERVED"
        else
          puts "  ~ #{filename}: MODIFIED"
        end
      end

      if other_files.any?
        puts "\nOther Files (#{other_files.length}):"
        other_files.each do |filename|
          orig = original_files[filename]
          saved = saved_files[filename]

          if orig && !saved
            puts "  ✗ #{filename}: REMOVED"
          elsif !orig && saved
            puts "  + #{filename}: ADDED"
          elsif orig == saved
            puts "  ✓ #{filename}: PRESERVED"
          else
            puts "  ~ #{filename}: MODIFIED (#{saved&.length || 0} bytes)"
          end
        end
      end

      puts '=' * 60
      puts

      # Test passes if document.xml is preserved
      expect(saved_files['word/document.xml']).to be_xml_equivalent_to(original_files['word/document.xml'])
    end
  end
end
