# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Docx.js Compatibility: Numbering and Lists', :compatibility do
  describe 'Numbered Lists' do
    describe 'basic numbering configuration' do
      it 'should support upper roman numeral format' do
        doc = Uniword::Document.new

        # Add paragraphs with upper roman numbering
        doc.add_paragraph('First item') do |para|
          para.numbering = {
            reference: 'roman-reference',
            level: 0
          }
        end

        doc.add_paragraph('Second item') do |para|
          para.numbering = {
            reference: 'roman-reference',
            level: 0
          }
        end

        # Verify numbering configuration
        expect(doc.paragraphs.count).to eq(2)
        expect(doc.paragraphs[0].numbering).to be_truthy
        expect(doc.paragraphs[1].numbering).to be_truthy
      end

      it 'should support decimal numbering format' do
        doc = Uniword::Document.new

        # Add paragraphs with decimal numbering
        doc.add_paragraph('Step 1 - Add sugar') do |para|
          para.numbering = {
            reference: 'decimal-reference',
            level: 0
          }
        end

        doc.add_paragraph('Step 2 - Add wheat') do |para|
          para.numbering = {
            reference: 'decimal-reference',
            level: 0
          }
        end

        doc.add_paragraph('Step 3 - Put in oven') do |para|
          para.numbering = {
            reference: 'decimal-reference',
            level: 0
          }
        end

        expect(doc.paragraphs.count).to eq(3)
        doc.paragraphs.each do |para|
          expect(para.numbering).to be_truthy
        end
      end

      it 'should support padded decimal format with custom text' do
        doc = Uniword::Document.new

        # Add paragraphs with padded decimal numbering
        doc.add_paragraph('Item with brackets') do |para|
          para.numbering = {
            reference: 'padded-reference',
            level: 0,
            format: 'decimal_zero', # e.g., [01], [02], etc.
            text: '[%1]'
          }
        end

        expect(doc.paragraphs.first.numbering).to be_truthy
      end
    end

    describe 'contextual spacing' do
      it 'should support contextual spacing in numbered paragraphs' do
        doc = Uniword::Document.new

        # Paragraphs with contextual spacing
        doc.add_paragraph('Line with contextual spacing') do |para|
          para.numbering = { reference: 'ref1', level: 0 }
          para.contextual_spacing = true
          para.spacing_before = 200
        end

        doc.add_paragraph('Another line with contextual spacing') do |para|
          para.numbering = { reference: 'ref1', level: 0 }
          para.contextual_spacing = true
          para.spacing_before = 200
        end

        expect(doc.paragraphs[0].contextual_spacing).to be true
        expect(doc.paragraphs[1].contextual_spacing).to be true
      end

      it 'should support disabling contextual spacing' do
        doc = Uniword::Document.new

        doc.add_paragraph('Line without contextual spacing') do |para|
          para.numbering = { reference: 'ref1', level: 0 }
          para.contextual_spacing = false
          para.spacing_before = 200
        end

        expect(doc.paragraphs.first.contextual_spacing).to be false
      end
    end

    describe 'numbering instances' do
      it 'should support restarting numbering with instances' do
        doc = Uniword::Document.new

        # First instance
        doc.add_paragraph('First list, item 1') do |para|
          para.numbering = {
            reference: 'padded-ref',
            level: 0,
            instance: 2
          }
        end

        doc.add_paragraph('First list, item 2') do |para|
          para.numbering = {
            reference: 'padded-ref',
            level: 0,
            instance: 2
          }
        end

        # Separator
        doc.add_paragraph('Next Section', heading: :heading_2)

        # Second instance (should restart numbering)
        doc.add_paragraph('Second list, item 1') do |para|
          para.numbering = {
            reference: 'padded-ref',
            level: 0,
            instance: 3
          }
        end

        doc.add_paragraph('Second list, item 2') do |para|
          para.numbering = {
            reference: 'padded-ref',
            level: 0,
            instance: 3
          }
        end

        expect(doc.paragraphs.select(&:numbering).count).to eq(4)
      end

      it 'should support continuing numbering without instance' do
        doc = Uniword::Document.new

        # Add multiple numbered items
        10.times do |i|
          doc.add_paragraph("Item #{i + 1}") do |para|
            para.numbering = {
              reference: 'continuous-ref',
              level: 0
            }
          end
        end

        numbered_paras = doc.paragraphs.select(&:numbering)
        expect(numbered_paras.count).to eq(10)
      end
    end

    describe 'multi-level numbering' do
      it 'should support nested numbering levels' do
        skip 'Multi-level numbering not yet implemented'

        doc = Uniword::Document.new

        # Level 0
        doc.add_paragraph('Level 0 item') do |para|
          para.numbering = { reference: 'multi-ref', level: 0 }
        end

        # Level 1 (indented)
        doc.add_paragraph('Level 1 item') do |para|
          para.numbering = { reference: 'multi-ref', level: 1 }
        end

        # Back to Level 0
        doc.add_paragraph('Back to level 0') do |para|
          para.numbering = { reference: 'multi-ref', level: 0 }
        end

        expect(doc.paragraphs[0].numbering[:level]).to eq(0)
        expect(doc.paragraphs[1].numbering[:level]).to eq(1)
        expect(doc.paragraphs[2].numbering[:level]).to eq(0)
      end
    end

    describe 'indentation with numbering' do
      it 'should support custom indentation for numbered lists' do
        skip 'Custom indentation for numbering not yet implemented'

        doc = Uniword::Document.new

        doc.add_paragraph('Indented numbered item') do |para|
          para.numbering = { reference: 'indent-ref', level: 0 }
          para.indent_left = 720 # 0.5 inch in twips
          para.indent_hanging = 259 # 0.18 inch in twips
        end

        para = doc.paragraphs.first
        expect(para.indent_left).to eq(720)
        expect(para.indent_hanging).to eq(259)
      end
    end
  end

  describe 'Bullet Points' do
    describe 'basic bullet lists' do
      it 'should support bullet point lists' do
        skip 'Bullet points not yet fully implemented'

        doc = Uniword::Document.new

        doc.add_paragraph('First bullet') do |para|
          para.bullet = true
        end

        doc.add_paragraph('Second bullet') do |para|
          para.bullet = true
        end

        expect(doc.paragraphs[0].bullet?).to be true
        expect(doc.paragraphs[1].bullet?).to be true
      end

      it 'should support custom bullet characters' do
        skip 'Custom bullet characters not yet implemented'

        doc = Uniword::Document.new

        doc.add_paragraph('Custom bullet') do |para|
          para.bullet = '•' # Custom character
        end

        expect(doc.paragraphs.first.bullet).to eq('•')
      end
    end

    describe 'mixed bullet and numbered lists' do
      it 'should support mixing bullets and numbers' do
        skip 'Mixed list types not yet fully implemented'

        doc = Uniword::Document.new

        # Numbered item
        doc.add_paragraph('Numbered item') do |para|
          para.numbering = { reference: 'num-ref', level: 0 }
        end

        # Bullet item
        doc.add_paragraph('Bullet item') do |para|
          para.bullet = true
        end

        # Another numbered item (different reference)
        doc.add_paragraph('Different numbered item') do |para|
          para.numbering = { reference: 'other-ref', level: 0 }
        end

        expect(doc.paragraphs[0].numbering).to be_truthy
        expect(doc.paragraphs[1].bullet?).to be true
        expect(doc.paragraphs[2].numbering).to be_truthy
      end
    end
  end

  describe 'Integration with document structure' do
    it 'should preserve numbering in round-trip' do
      skip 'Round-trip testing requires full implementation'

      # Create document with numbering
      original = Uniword::Document.new
      original.add_paragraph('Step 1') { |p| p.numbering = { reference: 'steps', level: 0 } }
      original.add_paragraph('Step 2') { |p| p.numbering = { reference: 'steps', level: 0 } }

      # Save and reload
      temp_path = '/tmp/numbering_test.docx'
      original.save(temp_path)
      reloaded = Uniword::Document.open(temp_path)

      # Verify numbering preserved
      expect(reloaded.paragraphs[0].numbering).to be_truthy
      expect(reloaded.paragraphs[1].numbering).to be_truthy
    end
  end
end
