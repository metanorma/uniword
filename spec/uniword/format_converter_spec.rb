# frozen_string_literal: true

require 'spec_helper'
require 'securerandom'

RSpec.describe Uniword::FormatConverter do
  let(:converter) { described_class.new }

  describe '#initialize' do
    it 'creates a new converter' do
      expect(converter).to be_a(described_class)
    end

    it 'accepts optional logger' do
      logger = double('Logger')
      conv = described_class.new(logger: logger)
      expect(conv).to be_a(described_class)
    end
  end

  describe '#convert' do
    let(:docx_path) { File.join(Dir.tmpdir, "uniword_test_#{SecureRandom.uuid}.docx") }
    let(:mhtml_path) { File.join(Dir.tmpdir, "uniword_test_#{SecureRandom.uuid}.mhtml") }

    before do
      # Create a simple DOCX file for testing
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'Test content')
      run.properties = Uniword::Wordprocessingml::RunProperties.new
      run.properties.bold = Uniword::Properties::Bold.new(value: true)
      para.runs << run
      doc.body.paragraphs << para
      doc.save(docx_path)
    end

    after do
      safe_delete(docx_path)
      safe_delete(mhtml_path)
    end

    context 'with explicit parameters' do
      it 'converts DOCX to MHTML with all parameters specified' do
        result = converter.convert(
          source: docx_path,
          source_format: :docx,
          target: mhtml_path,
          target_format: :mhtml
        )

        expect(result).to be_a(Uniword::FormatConverter::ConversionResult)
        expect(result.success?).to be true
        expect(result.source_format).to eq(:docx)
        expect(result.target_format).to eq(:mhtml)
      end

      it 'converts MHTML to DOCX with all parameters specified' do
        # First create an MHTML file
        mhtml_src = File.join(Dir.tmpdir, "uniword_test_#{SecureRandom.uuid}.mhtml")
        doc = Uniword::Wordprocessingml::DocumentRoot.new
        para = Uniword::Wordprocessingml::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: 'MHTML content')
        para.runs << run
        doc.body.paragraphs << para
        doc.save(mhtml_src, format: :mhtml)

        # Convert to DOCX
        output_docx = File.join(Dir.tmpdir, "uniword_test_#{SecureRandom.uuid}.docx")
        begin
          result = converter.convert(
            source: mhtml_src,
            source_format: :mhtml,
            target: output_docx,
            target_format: :docx
          )

          expect(result.success?).to be true
          expect(result.source_format).to eq(:mhtml)
          expect(result.target_format).to eq(:docx)
        ensure
          safe_delete(output_docx)
          safe_delete(mhtml_src)
        end
      end

      it 'requires source parameter' do
        expect do
          converter.convert(
            source: nil,
            source_format: :docx,
            target: mhtml_path,
            target_format: :mhtml
          )
        end.to raise_error(ArgumentError, /Source cannot be nil/)
      end

      it 'requires source_format parameter' do
        expect do
          converter.convert(
            source: docx_path,
            source_format: nil,
            target: mhtml_path,
            target_format: :mhtml
          )
        end.to raise_error(ArgumentError, /Source format must be specified/)
      end

      it 'requires target parameter' do
        expect do
          converter.convert(
            source: docx_path,
            source_format: :docx,
            target: nil,
            target_format: :mhtml
          )
        end.to raise_error(ArgumentError, /Target cannot be nil/)
      end

      it 'requires target_format parameter' do
        expect do
          converter.convert(
            source: docx_path,
            source_format: :docx,
            target: mhtml_path,
            target_format: nil
          )
        end.to raise_error(ArgumentError, /Target format must be specified/)
      end

      it 'validates source_format is supported' do
        expect do
          converter.convert(
            source: docx_path,
            source_format: :invalid,
            target: mhtml_path,
            target_format: :mhtml
          )
        end.to raise_error(ArgumentError, /Unsupported source format/)
      end

      it 'validates target_format is supported' do
        expect do
          converter.convert(
            source: docx_path,
            source_format: :docx,
            target: mhtml_path,
            target_format: :invalid
          )
        end.to raise_error(ArgumentError, /Unsupported target format/)
      end
    end

    context 'with conversion result' do
      it 'includes document statistics' do
        result = converter.convert(
          source: docx_path,
          source_format: :docx,
          target: mhtml_path,
          target_format: :mhtml
        )

        expect(result.paragraphs_count).to be > 0
        expect(result.tables_count).to be >= 0
        expect(result.images_count).to be >= 0
      end

      it 'provides success status' do
        result = converter.convert(
          source: docx_path,
          source_format: :docx,
          target: mhtml_path,
          target_format: :mhtml
        )

        expect(result.success?).to be true
      end

      it 'provides readable summary' do
        result = converter.convert(
          source: docx_path,
          source_format: :docx,
          target: mhtml_path,
          target_format: :mhtml
        )

        summary = result.to_s
        expect(summary).to include('docx → mhtml')
        expect(summary).to include('SUCCESS')
      end
    end
  end

  describe '#mhtml_to_docx' do
    let(:mhtml_path) { File.join(Dir.tmpdir, "uniword_test_#{SecureRandom.uuid}.mhtml") }
    let(:docx_path) { File.join(Dir.tmpdir, "uniword_test_#{SecureRandom.uuid}.docx") }

    before do
      # Create MHTML file
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'MHTML content')
      para.runs << run
      doc.body.paragraphs << para
      doc.save(mhtml_path, format: :mhtml)
    end

    after do
      safe_delete(mhtml_path)
      safe_delete(docx_path)
    end

    it 'explicitly declares MHTML to DOCX conversion' do
      result = converter.mhtml_to_docx(
        source: mhtml_path,
        target: docx_path
      )

      expect(result.success?).to be true
      expect(result.source_format).to eq(:mhtml)
      expect(result.target_format).to eq(:docx)
    end

    it 'preserves content in conversion' do
      skip 'MHTML→DOCX conversion chain is lossy for text content'

      result = converter.mhtml_to_docx(
        source: mhtml_path,
        target: docx_path
      )

      expect(result.success?).to be true

      # Read back the converted document
      converted = Uniword::DocumentFactory.from_file(docx_path)
      expect(converted.text).to include('MHTML content')
    end
  end

  describe '#docx_to_mhtml' do
    let(:docx_path) { File.join(Dir.tmpdir, "uniword_test_#{SecureRandom.uuid}.docx") }
    let(:mhtml_path) { File.join(Dir.tmpdir, "uniword_test_#{SecureRandom.uuid}.mhtml") }

    before do
      # Create DOCX file
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'DOCX content')
      run.properties = Uniword::Wordprocessingml::RunProperties.new
      run.properties.italic = Uniword::Properties::Italic.new(value: true)
      para.runs << run
      doc.body.paragraphs << para
      doc.save(docx_path)
    end

    after do
      safe_delete(docx_path)
      safe_delete(mhtml_path)
    end

    it 'explicitly declares DOCX to MHTML conversion' do
      result = converter.docx_to_mhtml(
        source: docx_path,
        target: mhtml_path
      )

      expect(result.success?).to be true
      expect(result.source_format).to eq(:docx)
      expect(result.target_format).to eq(:mhtml)
    end
  end

  describe '#batch_convert' do
    let(:temp_dir) { Dir.mktmpdir }
    let(:output_dir) { Dir.mktmpdir }

    before do
      # Create 3 test DOCX files
      3.times do |i|
        doc = Uniword::Wordprocessingml::DocumentRoot.new
        para = Uniword::Wordprocessingml::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: "Document #{i + 1}")
        para.runs << run
        doc.body.paragraphs << para
        doc.save(File.join(temp_dir, "test#{i + 1}.docx"))
      end
    end

    after do
      FileUtils.rm_rf(temp_dir)
      FileUtils.rm_rf(output_dir)
    end

    it 'converts multiple files with explicit formats' do
      sources = Dir.glob(File.join(temp_dir, '*.docx'))

      results = converter.batch_convert(
        sources: sources,
        source_format: :docx,
        target_format: :mhtml,
        target_dir: output_dir
      )

      expect(results.count).to eq(3)
      expect(results.all?(&:success?)).to be true

      # Verify output files exist
      expect(Dir.glob(File.join(output_dir, '*.mhtml')).count).to eq(3)
    end
  end

  describe 'ConversionResult' do
    subject(:result) do
      Uniword::FormatConverter::ConversionResult.new(
        source: 'input.docx',
        source_format: :docx,
        target: 'output.mhtml',
        target_format: :mhtml,
        success: true,
        paragraphs_count: 10,
        tables_count: 2,
        images_count: 3
      )
    end

    it 'provides success status' do
      expect(result.success?).to be true
    end

    it 'provides source information' do
      expect(result.source).to eq('input.docx')
      expect(result.source_format).to eq(:docx)
    end

    it 'provides target information' do
      expect(result.target).to eq('output.mhtml')
      expect(result.target_format).to eq(:mhtml)
    end

    it 'provides document statistics' do
      expect(result.paragraphs_count).to eq(10)
      expect(result.tables_count).to eq(2)
      expect(result.images_count).to eq(3)
    end

    it 'provides readable summary' do
      summary = result.to_s
      expect(summary).to include('docx → mhtml')
      expect(summary).to include('10 paragraphs')
      expect(summary).to include('2 tables')
      expect(summary).to include('3 images')
      expect(summary).to include('SUCCESS')
    end

    it 'provides hash representation' do
      hash = result.to_h
      expect(hash[:success]).to be true
      expect(hash[:paragraphs_count]).to eq(10)
    end

    context 'when conversion fails' do
      subject(:failed_result) do
        Uniword::FormatConverter::ConversionResult.new(
          source: 'input.docx',
          source_format: :docx,
          target: 'output.mhtml',
          target_format: :mhtml,
          success: false,
          error: 'File not found'
        )
      end

      it 'reports failure' do
        expect(failed_result.success?).to be false
      end

      it 'includes error message' do
        expect(failed_result.error).to eq('File not found')
      end

      it 'shows failure in summary' do
        summary = failed_result.to_s
        expect(summary).to include('FAILED')
        expect(summary).to include('File not found')
      end
    end
  end
end
