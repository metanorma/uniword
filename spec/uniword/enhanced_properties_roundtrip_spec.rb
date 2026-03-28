# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'
require 'uniword/builder'

RSpec.describe 'Enhanced Properties Round-Trip' do
  let(:test_dir) { File.join(__dir__, '..', '..', 'tmp', 'roundtrip_test') }
  let(:test_file) { File.join(test_dir, 'enhanced_props_test.docx') }

  before do
    FileUtils.mkdir_p(test_dir)
  end

  after do
    FileUtils.rm_rf(test_dir)
  end

  def create_para(doc, text)
    para = Uniword::Wordprocessingml::Paragraph.new
    run = Uniword::Wordprocessingml::Run.new(text: text)
    para.runs << run
    doc.body.paragraphs << para
    para
  end

  describe 'paragraph enhanced properties' do
    it 'preserves paragraph borders through round-trip' do
      # Create document with borders
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = create_para(doc, 'Text with borders')
      Uniword::Builder::ParagraphBuilder.new(para).borders(
        top: { style: 'single', color: 'FF0000', size: 4 },
        bottom: { style: 'double', color: '0000FF', size: 6 }
      )

      # Save and reload
      doc.save(test_file)
      loaded_doc = Uniword.load(test_file)

      # Verify properties preserved
      loaded_para = loaded_doc.body.paragraphs.first
      expect(loaded_para.properties.borders).not_to be_nil
      expect(loaded_para.properties.borders.top).not_to be_nil
      expect(loaded_para.properties.borders.top.color).to eq('FF0000')
      expect(loaded_para.properties.borders.top.style).to eq('single')
      expect(loaded_para.properties.borders.top.size).to eq(4)
      expect(loaded_para.properties.borders.bottom).not_to be_nil
      expect(loaded_para.properties.borders.bottom.color).to eq('0000FF')
      expect(loaded_para.properties.borders.bottom.style).to eq('double')
      expect(loaded_para.properties.borders.bottom.size).to eq(6)
    end

    it 'preserves paragraph shading through round-trip' do
      # Create document with shading
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = create_para(doc, 'Shaded text')
      Uniword::Builder::ParagraphBuilder.new(para).shading(
        fill: 'FFFF00', pattern: 'solid'
      )

      # Save and reload
      doc.save(test_file)
      loaded_doc = Uniword.load(test_file)

      # Verify shading preserved
      loaded_para = loaded_doc.body.paragraphs.first
      expect(loaded_para.properties.shading).not_to be_nil
      expect(loaded_para.properties.shading.fill).to eq('FFFF00')
      expect(loaded_para.properties.shading.shading_type).to eq('solid')
    end

    it 'preserves tab stops through round-trip' do
      # Create document with tab stops
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = create_para(doc, "Text\twith\ttabs")
      builder = Uniword::Builder::ParagraphBuilder.new(para)
      builder << Uniword::Builder.tab_stop(
        position: 1440, alignment: 'center', leader: 'dot'
      )
      builder << Uniword::Builder.tab_stop(
        position: 2880, alignment: 'right'
      )

      # Save and reload
      doc.save(test_file)
      loaded_doc = Uniword.load(test_file)

      # Verify tab stops preserved
      loaded_para = loaded_doc.body.paragraphs.first
      expect(loaded_para.properties.tab_stops).not_to be_nil
      expect(loaded_para.properties.tab_stops.tabs.size).to eq(2)

      tab1 = loaded_para.properties.tab_stops.tabs[0]
      expect(tab1.position).to eq(1440)
      expect(tab1.alignment).to eq('center')
      expect(tab1.leader).to eq('dot')

      tab2 = loaded_para.properties.tab_stops.tabs[1]
      expect(tab2.position).to eq(2880)
      expect(tab2.alignment).to eq('right')
    end
  end

  describe 'run enhanced properties' do
    it 'preserves character spacing through round-trip' do
      # Create document with character spacing
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = create_para(doc, 'Spaced text')
      run = para.runs.first
      Uniword::Builder::RunBuilder.new(run).character_spacing(20)

      # Save and reload
      doc.save(test_file)
      loaded_doc = Uniword.load(test_file)

      # Verify character spacing preserved
      loaded_para = loaded_doc.body.paragraphs.first
      loaded_run = loaded_para.runs.first
      expect(loaded_run.properties.character_spacing).not_to be_nil
      expect(loaded_run.properties.character_spacing.val).to eq(20)
    end

    it 'preserves kerning through round-trip' do
      # Create document with kerning
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = create_para(doc, 'Kerned text')
      run = para.runs.first
      Uniword::Builder::RunBuilder.new(run).kerning(24)

      # Save and reload
      doc.save(test_file)
      loaded_doc = Uniword.load(test_file)

      # Verify kerning preserved
      loaded_para = loaded_doc.body.paragraphs.first
      loaded_run = loaded_para.runs.first
      expect(loaded_run.properties.kerning).not_to be_nil
      expect(loaded_run.properties.kerning.val).to eq(24)
    end

    it 'preserves position through round-trip' do
      # Create document with raised text
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = create_para(doc, 'Raised text')
      run = para.runs.first
      Uniword::Builder::RunBuilder.new(run).position(5)

      # Save and reload
      doc.save(test_file)
      loaded_doc = Uniword.load(test_file)

      # Verify position preserved
      loaded_para = loaded_doc.body.paragraphs.first
      loaded_run = loaded_para.runs.first
      expect(loaded_run.properties.position).not_to be_nil
      expect(loaded_run.properties.position.val).to eq(5)
    end

    it 'preserves text expansion through round-trip' do
      # Create document with expanded text
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = create_para(doc, 'Expanded text')
      run = para.runs.first
      Uniword::Builder::RunBuilder.new(run).text_expansion(120)

      # Save and reload
      doc.save(test_file)
      loaded_doc = Uniword.load(test_file)

      # Verify text expansion preserved
      loaded_para = loaded_doc.body.paragraphs.first
      loaded_run = loaded_para.runs.first
      expect(loaded_run.properties.text_expansion).not_to be_nil
      expect(loaded_run.properties.text_expansion.val).to eq(120)
    end

    it 'preserves emphasis mark through round-trip' do
      # Create document with emphasis mark
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = create_para(doc, 'Emphasized text')
      run = para.runs.first
      Uniword::Builder::RunBuilder.new(run).emphasis_mark('dot')

      # Save and reload
      doc.save(test_file)
      loaded_doc = Uniword.load(test_file)

      # Verify emphasis mark preserved
      loaded_para = loaded_doc.body.paragraphs.first
      loaded_run = loaded_para.runs.first
      expect(loaded_run.properties.emphasis_mark).not_to be_nil
      expect(loaded_run.properties.emphasis_mark.val).to eq('dot')
    end

    it 'preserves language through round-trip' do
      # Create document with language setting
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = create_para(doc, 'English text')
      run = para.runs.first
      Uniword::Builder::RunBuilder.new(run).language('en-US')

      # Save and reload
      doc.save(test_file)
      loaded_doc = Uniword.load(test_file)

      # Verify language preserved
      loaded_para = loaded_doc.body.paragraphs.first
      loaded_run = loaded_para.runs.first
      expect(loaded_run.properties.language).not_to be_nil
      expect(loaded_run.properties.language.val).to eq('en-US')
    end

    it 'preserves text effects through round-trip' do
      # Create document with text effects
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = create_para(doc, 'Text with effects')
      run = para.runs.first
      builder = Uniword::Builder::RunBuilder.new(run)
      builder.outline
      builder.shadow
      builder.emboss

      # Save and reload
      doc.save(test_file)
      loaded_doc = Uniword.load(test_file)

      # Verify text effects preserved
      loaded_para = loaded_doc.body.paragraphs.first
      loaded_run = loaded_para.runs.first
      expect(loaded_run.properties.outline).to be_truthy
      expect(loaded_run.properties.shadow).to be_truthy
      expect(loaded_run.properties.emboss).to be_truthy
    end
  end

  describe 'complex combinations' do
    it 'preserves multiple paragraph properties through round-trip' do
      # Create document with multiple properties
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = create_para(doc, 'Complex paragraph')
      builder = Uniword::Builder::ParagraphBuilder.new(para)
      builder.borders(top: '000000', bottom: 'FF0000')
      builder.shading(fill: 'FFFF00', pattern: 'solid')
      builder << Uniword::Builder.tab_stop(
        position: 1440, alignment: 'center'
      )

      # Save and reload
      doc.save(test_file)
      loaded_doc = Uniword.load(test_file)

      # Verify all properties preserved
      loaded_para = loaded_doc.body.paragraphs.first
      expect(loaded_para.properties.borders).not_to be_nil
      expect(loaded_para.properties.shading).not_to be_nil
      expect(loaded_para.properties.tab_stops).not_to be_nil
    end

    it 'preserves multiple run properties through round-trip' do
      # Create document with multiple run properties
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = create_para(doc, 'Complex run')
      run = para.runs.first
      builder = Uniword::Builder::RunBuilder.new(run)
      builder.character_spacing(20)
      builder.kerning(24)
      builder.position(5)
      builder.outline
      builder.shadow

      # Save and reload
      doc.save(test_file)
      loaded_doc = Uniword.load(test_file)

      # Verify all properties preserved
      loaded_para = loaded_doc.body.paragraphs.first
      loaded_run = loaded_para.runs.first
      expect(loaded_run.properties.character_spacing).not_to be_nil
      expect(loaded_run.properties.kerning).not_to be_nil
      expect(loaded_run.properties.position).not_to be_nil
      expect(loaded_run.properties.outline).to be_truthy
      expect(loaded_run.properties.shadow).to be_truthy
    end

    it 'preserves properties across multiple paragraphs' do
      # Create document with multiple paragraphs
      doc = Uniword::Wordprocessingml::DocumentRoot.new

      para1 = create_para(doc, 'Paragraph 1')
      Uniword::Builder::ParagraphBuilder.new(para1).borders(top: 'FF0000')

      para2 = create_para(doc, 'Paragraph 2')
      Uniword::Builder::ParagraphBuilder.new(para2).shading(fill: '00FF00')

      para3 = create_para(doc, 'Paragraph 3')
      Uniword::Builder::ParagraphBuilder.new(para3) << Uniword::Builder.tab_stop(
        position: 1440
      )

      # Save and reload
      doc.save(test_file)
      loaded_doc = Uniword.load(test_file)

      # Verify each paragraph preserved its properties
      expect(loaded_doc.body.paragraphs.size).to eq(3)
      expect(loaded_doc.body.paragraphs[0].properties.borders).not_to be_nil
      expect(loaded_doc.body.paragraphs[1].properties.shading).not_to be_nil
      expect(loaded_doc.body.paragraphs[2].properties.tab_stops).not_to be_nil
    end
  end

  describe 'edge cases' do
    it 'preserves empty properties containers' do
      # Create document with paragraph but no enhanced properties
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      create_para(doc, 'Plain text')

      # Save and reload
      doc.save(test_file)
      loaded_doc = Uniword.load(test_file)

      # Document should load without errors
      expect(loaded_doc.body.paragraphs.size).to eq(1)
      expect(loaded_doc.body.paragraphs.first.text).to eq('Plain text')
    end

    it 'preserves negative values (character spacing, position)' do
      # Create document with negative values
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = create_para(doc, 'Condensed and lowered')
      run = para.runs.first
      builder = Uniword::Builder::RunBuilder.new(run)
      builder.character_spacing(-10) # Condensed
      builder.position(-5) # Lowered (subscript)

      # Save and reload
      doc.save(test_file)
      loaded_doc = Uniword.load(test_file)

      # Verify negative values preserved
      loaded_para = loaded_doc.body.paragraphs.first
      loaded_run = loaded_para.runs.first
      expect(loaded_run.properties.character_spacing.val).to eq(-10)
      expect(loaded_run.properties.position.val).to eq(-5)
    end
  end
end
