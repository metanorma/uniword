# frozen_string_literal: true

require 'spec_helper'
require 'canon/rspec_matchers'

RSpec.describe 'Ultimate Round-Trip: demo_formal_integral_proper.docx' do
  let(:input_file) { 'examples/demo_formal_integral_proper.docx' }
  let(:output_file) { 'examples/demo_formal_integral_roundtrip_spec.docx' }
  let(:original_dir) { 'examples/roundtrip_spec_original' }
  let(:saved_dir) { 'examples/roundtrip_spec_saved' }

  before(:all) do
    # Load and save document once for all tests
    @doc = Uniword::Document.open('examples/demo_formal_integral_proper.docx')
    @doc.save('examples/demo_formal_integral_roundtrip_spec.docx')

    # Extract both packages
    system('cd examples && unzip -qo demo_formal_integral_proper.docx -d roundtrip_spec_original')
    system('cd examples && unzip -qo demo_formal_integral_roundtrip_spec.docx -d roundtrip_spec_saved')
  end

  describe 'Document Loading' do
    it 'loads the document successfully' do
      expect(@doc).to be_a(Uniword::Document)
      expect(@doc.paragraphs.count).to be > 0
      expect(@doc.styles.count).to be > 0
    end

    it 'loads theme with media files' do
      pending 'Deserializer does not extract theme media from .docx yet'
      expect(@doc.theme).not_to be_nil
      expect(@doc.theme.media_files).not_to be_empty
    end
  end

  describe 'Core Content Files' do
    describe 'word/document.xml' do
      it 'is semantically equivalent after round-trip' do
        original = File.read("#{original_dir}/word/document.xml")
        saved = File.read("#{saved_dir}/word/document.xml")

        expect(saved).to be_xml_equivalent_to(original)
      end
    end

    describe 'word/styles.xml' do
      it 'is semantically equivalent after round-trip' do
        original = File.read("#{original_dir}/word/styles.xml")
        saved = File.read("#{saved_dir}/word/styles.xml")

        expect(saved).to be_xml_equivalent_to(original)
      end
    end

    describe 'word/theme/theme1.xml' do
      it 'is semantically equivalent after round-trip' do
        original = File.read("#{original_dir}/word/theme/theme1.xml")
        saved = File.read("#{saved_dir}/word/theme/theme1.xml")

        expect(saved).to be_xml_equivalent_to(original)
      end
    end
  end

  describe 'Supporting Files' do
    describe 'word/fontTable.xml' do
      it 'is semantically equivalent after round-trip' do
        original = File.read("#{original_dir}/word/fontTable.xml")
        saved = File.read("#{saved_dir}/word/fontTable.xml")

        expect(saved).to be_xml_equivalent_to(original)
      end
    end

    describe 'word/settings.xml' do
      it 'is semantically equivalent after round-trip' do
        original = File.read("#{original_dir}/word/settings.xml")
        saved = File.read("#{saved_dir}/word/settings.xml")

        expect(saved).to be_xml_equivalent_to(original)
      end
    end

    describe 'word/webSettings.xml' do
      it 'is semantically equivalent after round-trip' do
        original = File.read("#{original_dir}/word/webSettings.xml")
        saved = File.read("#{saved_dir}/word/webSettings.xml")

        expect(saved).to be_xml_equivalent_to(original)
      end
    end

    describe 'word/numbering.xml' do
      it 'is semantically equivalent after round-trip' do
        original = File.read("#{original_dir}/word/numbering.xml")
        saved = File.read("#{saved_dir}/word/numbering.xml")

        expect(saved).to be_xml_equivalent_to(original)
      end
    end
  end

  describe 'Package Files' do
    describe '[Content_Types].xml' do
      it 'is semantically equivalent after round-trip' do
        original = File.read("#{original_dir}/[Content_Types].xml")
        saved = File.read("#{saved_dir}/[Content_Types].xml")

        expect(saved).to be_xml_equivalent_to(original)
      end
    end

    describe '_rels/.rels' do
      it 'is semantically equivalent after round-trip' do
        original = File.read("#{original_dir}/_rels/.rels")
        saved = File.read("#{saved_dir}/_rels/.rels")

        expect(saved).to be_xml_equivalent_to(original)
      end
    end

    describe 'word/_rels/document.xml.rels' do
      it 'is semantically equivalent after round-trip' do
        original = File.read("#{original_dir}/word/_rels/document.xml.rels")
        saved = File.read("#{saved_dir}/word/_rels/document.xml.rels")

        expect(saved).to be_xml_equivalent_to(original)
      end
    end

    describe 'word/theme/_rels/theme1.xml.rels' do
      it 'is semantically equivalent after round-trip' do
        original = File.read("#{original_dir}/word/theme/_rels/theme1.xml.rels")
        saved = File.read("#{saved_dir}/word/theme/_rels/theme1.xml.rels")

        expect(saved).to be_xml_equivalent_to(original)
      end
    end
  end

  describe 'Metadata Files' do
    describe 'docProps/app.xml' do
      it 'is semantically equivalent after round-trip' do
        original = File.read("#{original_dir}/docProps/app.xml")
        saved = File.read("#{saved_dir}/docProps/app.xml")

        expect(saved).to be_xml_equivalent_to(original)
      end
    end

    describe 'docProps/core.xml' do
      it 'is semantically equivalent after round-trip' do
        original = File.read("#{original_dir}/docProps/core.xml")
        saved = File.read("#{saved_dir}/docProps/core.xml")

        expect(saved).to be_xml_equivalent_to(original)
      end
    end
  end

  describe 'Media Files' do
    it 'preserves media files' do
      pending 'Deserializer does not extract media from .docx yet'

      original_media = File.read("#{original_dir}/word/media/image1.jpeg")
      saved_media = File.read("#{saved_dir}/word/media/image1.jpeg")

      expect(saved_media).to eq(original_media)
    end
  end
end
