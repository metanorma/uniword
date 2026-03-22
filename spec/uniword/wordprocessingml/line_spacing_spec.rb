# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Line Spacing (RAW OOXML Values)' do
  describe 'Paragraph#line_spacing=' do
    let(:doc) { Uniword::Wordprocessingml::DocumentRoot.new }
    let(:para) { doc.add_paragraph('Test paragraph') }

    context 'with numeric value (RAW OOXML twips)' do
      it 'sets line spacing as raw twips value' do
        para.line_spacing = 360
        expect(para.line_spacing).to eq(360)
      end

      it 'sets line spacing with rule via two-arg method' do
        para.line_spacing(240, 'exact')
        expect(para.properties.spacing.line).to eq(240)
        expect(para.properties.spacing.line_rule).to eq('exact')
      end

      it 'sets line spacing with auto rule' do
        para.line_spacing(360, 'auto')
        expect(para.properties.spacing.line).to eq(360)
        expect(para.properties.spacing.line_rule).to eq('auto')
      end
    end

    context 'with hash format' do
      it 'sets exact line spacing' do
        para.line_spacing = { rule: 'exact', value: 240 }
        expect(para.properties.spacing.line).to eq(240)
        expect(para.properties.spacing.line_rule).to eq('exact')
      end

      it 'sets "at least" line spacing' do
        para.line_spacing = { rule: 'atLeast', value: 280 }
        expect(para.properties.spacing.line).to eq(280)
        expect(para.properties.spacing.line_rule).to eq('atLeast')
      end

      it 'normalizes "at_least" to "atLeast"' do
        para.line_spacing = { rule: 'at_least', value: 300 }
        expect(para.properties.spacing.line_rule).to eq('atLeast')
      end

      it 'handles string keys' do
        para.line_spacing = { 'rule' => 'exact', 'value' => 240 }
        expect(para.properties.spacing.line).to eq(240)
        expect(para.properties.spacing.line_rule).to eq('exact')
      end
    end
  end

  describe 'Paragraph#line_spacing getter' do
    let(:doc) { Uniword::Wordprocessingml::DocumentRoot.new }
    let(:para) { doc.add_paragraph('Test paragraph') }

    it 'returns raw integer value (twips)' do
      para.line_spacing = 360
      expect(para.line_spacing).to eq(360)
    end

    it 'returns nil when not set' do
      expect(para.line_spacing).to be_nil
    end
  end

  describe 'OOXML serialization' do
    let(:doc) { Uniword::Wordprocessingml::DocumentRoot.new }

    it 'serializes exact line spacing correctly' do
      para = doc.add_paragraph('Test')
      para.line_spacing = { rule: 'exact', value: 240 }

      xml = doc.to_xml(prefix: true)
      expect(xml).to include('w:lineRule="exact"')
      expect(xml).to include('w:line="240"')
    end

    it 'serializes auto line spacing correctly' do
      para = doc.add_paragraph('Test')
      para.line_spacing = { rule: 'auto', value: 360 }

      xml = doc.to_xml(prefix: true)
      expect(xml).to include('w:lineRule="auto"')
      expect(xml).to include('w:line="360"')
    end

    it 'serializes "at least" line spacing correctly' do
      para = doc.add_paragraph('Test')
      para.line_spacing = { rule: 'atLeast', value: 280 }

      xml = doc.to_xml(prefix: true)
      expect(xml).to include('w:lineRule="atLeast"')
      expect(xml).to include('w:line="280"')
    end
  end

  describe 'OOXML deserialization' do
    it 'deserializes exact line spacing' do
      xml = <<~XML
        <?xml version="1.0" encoding="UTF-8"?>
        <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
          <w:body>
            <w:p>
              <w:pPr>
                <w:spacing w:line="240" w:lineRule="exact"/>
              </w:pPr>
              <w:r><w:t>Test</w:t></w:r>
            </w:p>
          </w:body>
        </w:document>
      XML

      doc = Uniword::Wordprocessingml::DocumentRoot.from_xml(xml)
      para = doc.body.paragraphs.first
      expect(para.properties.spacing.line).to eq(240)
      expect(para.properties.spacing.line_rule).to eq('exact')
    end

    it 'deserializes auto line spacing' do
      xml = <<~XML
        <?xml version="1.0" encoding="UTF-8"?>
        <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
          <w:body>
            <w:p>
              <w:pPr>
                <w:spacing w:line="360" w:lineRule="auto"/>
              </w:pPr>
              <w:r><w:t>Test</w:t></w:r>
            </w:p>
          </w:body>
        </w:document>
      XML

      doc = Uniword::Wordprocessingml::DocumentRoot.from_xml(xml)
      para = doc.body.paragraphs.first
      expect(para.properties.spacing.line).to eq(360)
      expect(para.properties.spacing.line_rule).to eq('auto')
    end

    it 'deserializes "at least" line spacing' do
      xml = <<~XML
        <?xml version="1.0" encoding="UTF-8"?>
        <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
          <w:body>
            <w:p>
              <w:pPr>
                <w:spacing w:line="280" w:lineRule="atLeast"/>
              </w:pPr>
              <w:r><w:t>Test</w:t></w:r>
            </w:p>
          </w:body>
        </w:document>
      XML

      doc = Uniword::Wordprocessingml::DocumentRoot.from_xml(xml)
      para = doc.body.paragraphs.first
      expect(para.properties.spacing.line).to eq(280)
      expect(para.properties.spacing.line_rule).to eq('atLeast')
    end
  end

  describe 'Round-trip serialization' do
    it 'preserves exact line spacing through round-trip' do
      doc1 = Uniword::Wordprocessingml::DocumentRoot.new
      para1 = doc1.add_paragraph('Test')
      para1.line_spacing = { rule: 'exact', value: 240 }

      xml = doc1.to_xml(prefix: true)
      doc2 = Uniword::Wordprocessingml::DocumentRoot.from_xml(xml)
      para2 = doc2.body.paragraphs.first

      expect(para2.properties.spacing.line).to eq(240)
      expect(para2.properties.spacing.line_rule).to eq('exact')
    end

    it 'preserves auto line spacing through round-trip' do
      doc1 = Uniword::Wordprocessingml::DocumentRoot.new
      para1 = doc1.add_paragraph('Test')
      para1.line_spacing = { rule: 'auto', value: 360 }

      xml = doc1.to_xml(prefix: true)
      doc2 = Uniword::Wordprocessingml::DocumentRoot.from_xml(xml)
      para2 = doc2.body.paragraphs.first

      expect(para2.properties.spacing.line).to eq(360)
      expect(para2.properties.spacing.line_rule).to eq('auto')
    end

    it 'preserves "at least" line spacing through round-trip' do
      doc1 = Uniword::Wordprocessingml::DocumentRoot.new
      para1 = doc1.add_paragraph('Test')
      para1.line_spacing = { rule: 'atLeast', value: 280 }

      xml = doc1.to_xml(prefix: true)
      doc2 = Uniword::Wordprocessingml::DocumentRoot.from_xml(xml)
      para2 = doc2.body.paragraphs.first

      expect(para2.properties.spacing.line).to eq(280)
      expect(para2.properties.spacing.line_rule).to eq('atLeast')
    end
  end
end
