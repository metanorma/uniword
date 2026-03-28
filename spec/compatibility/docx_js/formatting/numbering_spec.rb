# frozen_string_literal: true

require 'spec_helper'
require 'uniword/builder'

RSpec.describe 'Docx.js Compatibility: Numbering and Lists', :compatibility do
  describe 'Numbered Lists' do
    describe 'basic numbering configuration' do
      it 'should support upper roman numeral format' do
        doc = Uniword::Document.new

        # Add paragraphs with upper roman numbering
        para1 = Uniword::Paragraph.new
        run1 = Uniword::Wordprocessingml::Run.new(text: 'First item')
        para1.runs << run1
        builder1 = Uniword::Builder::ParagraphBuilder.new(para1)
        builder1.numbering(1, 0)
        doc.body.paragraphs << para1

        para2 = Uniword::Paragraph.new
        run2 = Uniword::Wordprocessingml::Run.new(text: 'Second item')
        para2.runs << run2
        builder2 = Uniword::Builder::ParagraphBuilder.new(para2)
        builder2.numbering(1, 0)
        doc.body.paragraphs << para2

        # Verify numbering configuration
        expect(doc.paragraphs.count).to eq(2)
        expect(doc.paragraphs[0].properties&.num_id).to eq(1)
        expect(doc.paragraphs[1].properties&.num_id).to eq(1)
      end

      it 'should support decimal numbering format' do
        doc = Uniword::Document.new

        # Add paragraphs with decimal numbering
        para1 = Uniword::Paragraph.new
        run1 = Uniword::Wordprocessingml::Run.new(text: 'Step 1 - Add sugar')
        para1.runs << run1
        builder1 = Uniword::Builder::ParagraphBuilder.new(para1)
        builder1.numbering(2, 0)
        doc.body.paragraphs << para1

        para2 = Uniword::Paragraph.new
        run2 = Uniword::Wordprocessingml::Run.new(text: 'Step 2 - Add wheat')
        para2.runs << run2
        builder2 = Uniword::Builder::ParagraphBuilder.new(para2)
        builder2.numbering(2, 0)
        doc.body.paragraphs << para2

        para3 = Uniword::Paragraph.new
        run3 = Uniword::Wordprocessingml::Run.new(text: 'Step 3 - Put in oven')
        para3.runs << run3
        builder3 = Uniword::Builder::ParagraphBuilder.new(para3)
        builder3.numbering(2, 0)
        doc.body.paragraphs << para3

        expect(doc.paragraphs.count).to eq(3)
        doc.paragraphs.each do |para|
          expect(para.properties&.num_id).to be_truthy
        end
      end

      it 'should support padded decimal format with custom text' do
        doc = Uniword::Document.new

        # Add paragraphs with padded decimal numbering
        para = Uniword::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: 'Item with brackets')
        para.runs << run
        builder = Uniword::Builder::ParagraphBuilder.new(para)
        builder.numbering(3, 0)
        doc.body.paragraphs << para

        expect(doc.paragraphs.first.properties&.num_id).to be_truthy
      end
    end

    describe 'contextual spacing' do
      it 'should support contextual spacing in numbered paragraphs' do
        doc = Uniword::Document.new

        # Paragraphs with contextual spacing
        para1 = Uniword::Paragraph.new
        run1 = Uniword::Wordprocessingml::Run.new(text: 'Line with contextual spacing')
        para1.runs << run1
        builder1 = Uniword::Builder::ParagraphBuilder.new(para1)
        builder1.numbering(1, 0)
        builder1.contextual_spacing = true
        builder1.spacing(before: 200)
        doc.body.paragraphs << para1

        para2 = Uniword::Paragraph.new
        run2 = Uniword::Wordprocessingml::Run.new(text: 'Another line with contextual spacing')
        para2.runs << run2
        builder2 = Uniword::Builder::ParagraphBuilder.new(para2)
        builder2.numbering(1, 0)
        builder2.contextual_spacing = true
        builder2.spacing(before: 200)
        doc.body.paragraphs << para2

        expect(doc.paragraphs[0].properties&.contextual_spacing).to be true
        expect(doc.paragraphs[1].properties&.contextual_spacing).to be true
      end

      it 'should support disabling contextual spacing' do
        doc = Uniword::Document.new

        para = Uniword::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: 'Line without contextual spacing')
        para.runs << run
        builder = Uniword::Builder::ParagraphBuilder.new(para)
        builder.numbering(1, 0)
        builder.contextual_spacing = false
        builder.spacing(before: 200)
        doc.body.paragraphs << para

        expect(doc.paragraphs.first.properties&.contextual_spacing).to be false
      end
    end

    describe 'numbering instances' do
      it 'should support restarting numbering with instances' do
        doc = Uniword::Document.new

        # First instance
        para1 = Uniword::Paragraph.new
        run1 = Uniword::Wordprocessingml::Run.new(text: 'First list, item 1')
        para1.runs << run1
        builder1 = Uniword::Builder::ParagraphBuilder.new(para1)
        builder1.numbering(1, 0)
        doc.body.paragraphs << para1

        para2 = Uniword::Paragraph.new
        run2 = Uniword::Wordprocessingml::Run.new(text: 'First list, item 2')
        para2.runs << run2
        builder2 = Uniword::Builder::ParagraphBuilder.new(para2)
        builder2.numbering(1, 0)
        doc.body.paragraphs << para2

        # Separator
        sep = Uniword::Paragraph.new
        run_sep = Uniword::Wordprocessingml::Run.new(text: 'Next Section')
        sep.runs << run_sep
        doc.body.paragraphs << sep

        # Second instance (should restart numbering)
        para3 = Uniword::Paragraph.new
        run3 = Uniword::Wordprocessingml::Run.new(text: 'Second list, item 1')
        para3.runs << run3
        builder3 = Uniword::Builder::ParagraphBuilder.new(para3)
        builder3.numbering(2, 0)
        doc.body.paragraphs << para3

        para4 = Uniword::Paragraph.new
        run4 = Uniword::Wordprocessingml::Run.new(text: 'Second list, item 2')
        para4.runs << run4
        builder4 = Uniword::Builder::ParagraphBuilder.new(para4)
        builder4.numbering(2, 0)
        doc.body.paragraphs << para4

        numbered = doc.paragraphs.select { |p| p.properties&.num_id }
        expect(numbered.count).to eq(4)
      end

      it 'should support continuing numbering without instance' do
        doc = Uniword::Document.new

        # Add multiple numbered items
        10.times do |i|
          para = Uniword::Paragraph.new
          run = Uniword::Wordprocessingml::Run.new(text: "Item #{i + 1}")
          para.runs << run
          builder = Uniword::Builder::ParagraphBuilder.new(para)
          builder.numbering(1, 0)
          doc.body.paragraphs << para
        end

        numbered_paras = doc.paragraphs.select { |p| p.properties&.num_id }
        expect(numbered_paras.count).to eq(10)
      end
    end

    describe 'multi-level numbering' do
      it 'should support nested numbering levels' do
        skip 'Multi-level numbering not yet implemented'

        doc = Uniword::Document.new

        # Level 0
        para1 = Uniword::Paragraph.new
        run1 = Uniword::Wordprocessingml::Run.new(text: 'Level 0 item')
        para1.runs << run1
        builder1 = Uniword::Builder::ParagraphBuilder.new(para1)
        builder1.numbering(1, 0)
        doc.body.paragraphs << para1

        # Level 1 (indented)
        para2 = Uniword::Paragraph.new
        run2 = Uniword::Wordprocessingml::Run.new(text: 'Level 1 item')
        para2.runs << run2
        builder2 = Uniword::Builder::ParagraphBuilder.new(para2)
        builder2.numbering(1, 1)
        doc.body.paragraphs << para2

        # Back to Level 0
        para3 = Uniword::Paragraph.new
        run3 = Uniword::Wordprocessingml::Run.new(text: 'Back to level 0')
        para3.runs << run3
        builder3 = Uniword::Builder::ParagraphBuilder.new(para3)
        builder3.numbering(1, 0)
        doc.body.paragraphs << para3

        expect(doc.paragraphs[0].properties&.ilvl).to eq(0)
        expect(doc.paragraphs[1].properties&.ilvl).to eq(1)
        expect(doc.paragraphs[2].properties&.ilvl).to eq(0)
      end
    end

    describe 'indentation with numbering' do
      it 'should support custom indentation for numbered lists' do
        skip 'Custom indentation for numbering not yet implemented'

        doc = Uniword::Document.new

        para = Uniword::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: 'Indented numbered item')
        para.runs << run
        builder = Uniword::Builder::ParagraphBuilder.new(para)
        builder.numbering(1, 0)
        builder.indent(left: 720, hanging: 259)
        doc.body.paragraphs << para

        para = doc.paragraphs.first
        expect(para.properties&.indentation&.left).to eq(720)
        expect(para.properties&.indentation&.hanging).to eq(259)
      end
    end
  end

  describe 'Bullet Points' do
    describe 'basic bullet lists' do
      it 'should support bullet point lists' do
        skip 'Bullet points not yet fully implemented'

        doc = Uniword::Document.new

        para1 = Uniword::Paragraph.new
        run1 = Uniword::Wordprocessingml::Run.new(text: 'First bullet')
        para1.runs << run1
        para1.bullet = true
        doc.body.paragraphs << para1

        para2 = Uniword::Paragraph.new
        run2 = Uniword::Wordprocessingml::Run.new(text: 'Second bullet')
        para2.runs << run2
        para2.bullet = true
        doc.body.paragraphs << para2

        expect(doc.paragraphs[0].bullet?).to be true
        expect(doc.paragraphs[1].bullet?).to be true
      end

      it 'should support custom bullet characters' do
        skip 'Custom bullet characters not yet implemented'

        doc = Uniword::Document.new

        para = Uniword::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: 'Custom bullet')
        para.runs << run
        para.bullet = '•' # Custom character
        doc.body.paragraphs << para

        expect(doc.paragraphs.first.bullet).to eq('•')
      end
    end

    describe 'mixed bullet and numbered lists' do
      it 'should support mixing bullets and numbers' do
        skip 'Mixed list types not yet fully implemented'

        doc = Uniword::Document.new

        # Numbered item
        para1 = Uniword::Paragraph.new
        run1 = Uniword::Wordprocessingml::Run.new(text: 'Numbered item')
        para1.runs << run1
        builder1 = Uniword::Builder::ParagraphBuilder.new(para1)
        builder1.numbering(1, 0)
        doc.body.paragraphs << para1

        # Bullet item
        para2 = Uniword::Paragraph.new
        run2 = Uniword::Wordprocessingml::Run.new(text: 'Bullet item')
        para2.runs << run2
        para2.bullet = true
        doc.body.paragraphs << para2

        # Another numbered item (different reference)
        para3 = Uniword::Paragraph.new
        run3 = Uniword::Wordprocessingml::Run.new(text: 'Different numbered item')
        para3.runs << run3
        builder3 = Uniword::Builder::ParagraphBuilder.new(para3)
        builder3.numbering(2, 0)
        doc.body.paragraphs << para3

        expect(doc.paragraphs[0].properties&.num_id).to be_truthy
        expect(doc.paragraphs[1].bullet?).to be true
        expect(doc.paragraphs[2].properties&.num_id).to be_truthy
      end
    end
  end

  describe 'Integration with document structure' do
    it 'should preserve numbering in round-trip' do
      skip 'Round-trip testing requires full implementation'

      # Create document with numbering
      original = Uniword::Document.new
      para1 = Uniword::Paragraph.new
      run1 = Uniword::Wordprocessingml::Run.new(text: 'Step 1')
      para1.runs << run1
      builder1 = Uniword::Builder::ParagraphBuilder.new(para1)
      builder1.numbering(1, 0)
      original.body.paragraphs << para1

      para2 = Uniword::Paragraph.new
      run2 = Uniword::Wordprocessingml::Run.new(text: 'Step 2')
      para2.runs << run2
      builder2 = Uniword::Builder::ParagraphBuilder.new(para2)
      builder2.numbering(1, 0)
      original.body.paragraphs << para2

      # Save and reload
      temp_path = '/tmp/numbering_test.docx'
      original.save(temp_path)
      reloaded = Uniword.load(temp_path)

      # Verify numbering preserved
      expect(reloaded.paragraphs[0].properties&.num_id).to be_truthy
      expect(reloaded.paragraphs[1].properties&.num_id).to be_truthy
    end
  end
end
