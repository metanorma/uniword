# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Batch Processing Stages' do
  let(:document) { Uniword::Wordprocessingml::DocumentRoot.new }
  let(:context) do
    { filename: 'test.docx', input_path: 'input/test.docx', output_path: 'output/test.docx' }
  end

  describe Uniword::Batch::NormalizeStylesStage do
    let(:stage) { described_class.new }

    it 'initializes with default options' do
      expect(stage.enabled?).to be true
    end

    it 'processes document' do
      result = stage.process(document, context)
      expect(result).to eq(document)
    end

    it 'has correct name' do
      expect(stage.name).to eq('normalize_styles')
    end

    it 'provides description' do
      expect(stage.description).to eq('Normalize document styles')
    end

    it 'accepts custom options' do
      stage = described_class.new(
        remove_direct_formatting: false,
        apply_standard_styles: true
      )
      expect(stage.options[:remove_direct_formatting]).to be false
      expect(stage.options[:apply_standard_styles]).to be true
    end
  end

  describe Uniword::Batch::UpdateMetadataStage do
    let(:stage) { described_class.new }

    it 'initializes with default options' do
      expect(stage.enabled?).to be true
    end

    it 'processes document' do
      result = stage.process(document, context)
      expect(result).to eq(document)
    end

    it 'has correct name' do
      expect(stage.name).to eq('update_metadata')
    end

    it 'provides description' do
      expect(stage.description).to eq('Update document metadata')
    end

    it 'accepts custom author' do
      stage = described_class.new(author: 'Test Author')
      expect(stage.options[:author]).to eq('Test Author')
    end

    it 'accepts company and title' do
      stage = described_class.new(
        company: 'Test Corp',
        title: 'Test Document'
      )
      expect(stage.options[:company]).to eq('Test Corp')
      expect(stage.options[:title]).to eq('Test Document')
    end
  end

  describe Uniword::Batch::ValidateLinksStage do
    let(:stage) { described_class.new }

    it 'initializes with default options' do
      expect(stage.enabled?).to be true
    end

    it 'processes document' do
      result = stage.process(document, context)
      expect(result).to eq(document)
    end

    it 'has correct name' do
      expect(stage.name).to eq('validate_links')
    end

    it 'provides description' do
      expect(stage.description).to eq('Validate document links')
    end

    it 'accepts link checking options' do
      stage = described_class.new(
        check_internal: true,
        check_external: false,
        check_bookmarks: true
      )
      expect(stage.options[:check_internal]).to be true
      expect(stage.options[:check_external]).to be false
      expect(stage.options[:check_bookmarks]).to be true
    end

    it 'accepts broken link action' do
      stage = described_class.new(broken_link_action: 'remove')
      expect(stage.options[:broken_link_action]).to eq('remove')
    end
  end

  describe Uniword::Batch::ConvertFormatStage do
    let(:stage) { described_class.new(target_format: :docx) }

    it 'initializes with target format' do
      expect(stage.enabled?).to be true
      expect(stage.options[:target_format]).to eq(:docx)
    end

    it 'processes document' do
      result = stage.process(document, context)
      expect(result).to eq(document)
    end

    it 'has correct name' do
      expect(stage.name).to eq('convert_format')
    end

    it 'provides description' do
      expect(stage.description).to eq('Convert document format to docx')
    end

    it 'validates target format' do
      expect { described_class.new(target_format: :invalid) }.to raise_error(ArgumentError)
    end

    it 'accepts docx format' do
      stage = described_class.new(target_format: :docx)
      expect(stage.options[:target_format]).to eq(:docx)
    end

    it 'accepts mhtml format' do
      stage = described_class.new(target_format: :mhtml)
      expect(stage.options[:target_format]).to eq(:mhtml)
    end
  end

  describe Uniword::Batch::CompressImagesStage do
    let(:stage) { described_class.new }

    it 'initializes with default options' do
      expect(stage.enabled?).to be true
    end

    it 'processes document' do
      result = stage.process(document, context)
      expect(result).to eq(document)
    end

    it 'has correct name' do
      expect(stage.name).to eq('compress_images')
    end

    it 'provides description' do
      expect(stage.description).to eq('Compress document images')
    end

    it 'accepts image size options' do
      stage = described_class.new(
        max_width: 1920,
        max_height: 1080,
        quality: 85
      )
      expect(stage.options[:max_width]).to eq(1920)
      expect(stage.options[:max_height]).to eq(1080)
      expect(stage.options[:quality]).to eq(85)
    end

    it 'accepts compression options' do
      stage = described_class.new(
        preserve_aspect_ratio: true,
        skip_small_images: true,
        min_size_kb: 100
      )
      expect(stage.options[:preserve_aspect_ratio]).to be true
      expect(stage.options[:skip_small_images]).to be true
      expect(stage.options[:min_size_kb]).to eq(100)
    end
  end

  describe Uniword::Batch::QualityCheckStage do
    let(:stage) { described_class.new }

    it 'initializes with default options' do
      expect(stage.enabled?).to be true
    end

    it 'processes document' do
      result = stage.process(document, context)
      expect(result).to eq(document)
    end

    it 'has correct name' do
      expect(stage.name).to eq('quality_check')
    end

    it 'provides description' do
      expect(stage.description).to eq('Run quality checks')
    end

    it 'accepts rules file option' do
      stage = described_class.new(rules_file: 'custom_rules.yml')
      expect(stage.options[:rules_file]).to eq('custom_rules.yml')
    end

    it 'accepts failure options' do
      stage = described_class.new(
        fail_on_errors: true,
        fail_on_warnings: false,
        generate_report: true
      )
      expect(stage.options[:fail_on_errors]).to be true
      expect(stage.options[:fail_on_warnings]).to be false
      expect(stage.options[:generate_report]).to be true
    end
  end

  describe 'Stage inheritance' do
    [
      Uniword::Batch::NormalizeStylesStage,
      Uniword::Batch::UpdateMetadataStage,
      Uniword::Batch::ValidateLinksStage,
      Uniword::Batch::ConvertFormatStage,
      Uniword::Batch::CompressImagesStage,
      Uniword::Batch::QualityCheckStage
    ].each do |stage_class|
      it "#{stage_class} inherits from ProcessingStage" do
        expect(stage_class.superclass).to eq(Uniword::Batch::ProcessingStage)
      end

      it "#{stage_class} implements process method" do
        stage = stage_class.new
        expect(stage).to respond_to(:process)
      end

      it "#{stage_class} has name method" do
        stage = stage_class.new
        expect(stage.name).to be_a(String)
        expect(stage.name).not_to be_empty
      end

      it "#{stage_class} has description method" do
        stage = stage_class.new
        expect(stage.description).to be_a(String)
        expect(stage.description).not_to be_empty
      end
    end
  end
end
