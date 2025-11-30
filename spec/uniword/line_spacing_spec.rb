# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Line Spacing Fine Control' do
  describe 'Paragraph#line_spacing=' do
    let(:doc) { Uniword::Document.new }
    let(:para) { doc.add_paragraph('Test paragraph') }

    context 'with numeric value (simple API)' do
      it 'sets line spacing as multiple (1.5x)' do
        para.line_spacing = 1.5
        expect(para.properties.line_spacing).to eq(1.5)
        expect(para.properties.line_rule).to eq('auto')
      end

      it 'sets line spacing as single (1.0x)' do
        para.line_spacing = 1.0
        expect(para.properties.line_spacing).to eq(1.0)
        expect(para.properties.line_rule).to eq('auto')
      end

      it 'sets line spacing as double (2.0x)' do
        para.line_spacing = 2.0
        expect(para.properties.line_spacing).to eq(2.0)
        expect(para.properties.line_rule).to eq('auto')
      end
    end

    context 'with hash format (fine-grained API)' do
      it 'sets exact line spacing' do
        para.line_spacing = { rule: 'exact', value: 240 }
        expect(para.properties.line_spacing).to eq(240.0)
        expect(para.properties.line_rule).to eq('exact')
      end

      it 'sets "at least" line spacing' do
        para.line_spacing = { rule: 'atLeast', value: 280 }
        expect(para.properties.line_spacing).to eq(280.0)
        expect(para.properties.line_rule).to eq('atLeast')
      end

      it 'sets multiple line spacing via hash' do
        para.line_spacing = { rule: 'multiple', value: 1.5 }
        expect(para.properties.line_spacing).to eq(1.5)
        expect(para.properties.line_rule).to eq('auto')
      end

      it 'normalizes "at_least" to "atLeast"' do
        para.line_spacing = { rule: 'at_least', value: 300 }
        expect(para.properties.line_rule).to eq('atLeast')
      end

      it 'handles string keys' do
        para.line_spacing = { 'rule' => 'exact', 'value' => 240 }
        expect(para.properties.line_spacing).to eq(240.0)
        expect(para.properties.line_rule).to eq('exact')
      end
    end
  end

  describe 'Paragraph#line_spacing getter' do
    let(:doc) { Uniword::Document.new }
    let(:para) { doc.add_paragraph('Test paragraph') }

    it 'returns hash with rule and value when rule is set' do
      para.line_spacing = { rule: 'exact', value: 240 }
      result = para.line_spacing
      expect(result).to be_a(Hash)
      expect(result[:rule]).to eq('exact')
      expect(result[:value]).to eq(240.0)
    end

    it 'returns numeric value for auto/multiple spacing' do
      para.line_spacing = 1.5
      result = para.line_spacing
      expect(result).to eq(1.5)
    end
  end

  describe 'OOXML serialization' do
    let(:doc) { Uniword::Document.new }
    let(:serializer) { Uniword::Serialization::OoxmlSerializer.new }

    it 'serializes exact line spacing correctly' do
      para = doc.add_paragraph('Test')
      para.line_spacing = { rule: 'exact', value: 240 }

      xml = serializer.serialize(doc)
      expect(xml).to include('w:lineRule="exact"')
      expect(xml).to include('w:line="240"')
    end

    it 'serializes multiple line spacing correctly' do
      para = doc.add_paragraph('Test')
      para.line_spacing = 1.5

      xml = serializer.serialize(doc)
      expect(xml).to include('w:lineRule="auto"')
      expect(xml).to include('w:line="360"') # 1.5 * 240 = 360
    end

    it 'serializes "at least" line spacing correctly' do
      para = doc.add_paragraph('Test')
      para.line_spacing = { rule: 'atLeast', value: 280 }

      xml = serializer.serialize(doc)
      expect(xml).to include('w:lineRule="atLeast"')
      expect(xml).to include('w:line="280"')
    end
  end

  describe 'OOXML deserialization' do
    let(:deserializer) { Uniword::Serialization::OoxmlDeserializer.new }

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

      doc = deserializer.deserialize(xml)
      para = doc.paragraphs.first
      expect(para.properties.line_spacing).to eq(240.0)
      expect(para.properties.line_rule).to eq('exact')
    end

    it 'deserializes multiple line spacing' do
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

      doc = deserializer.deserialize(xml)
      para = doc.paragraphs.first
      expect(para.properties.line_spacing).to eq(1.5) # 360 / 240 = 1.5
      expect(para.properties.line_rule).to eq('auto')
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

      doc = deserializer.deserialize(xml)
      para = doc.paragraphs.first
      expect(para.properties.line_spacing).to eq(280.0)
      expect(para.properties.line_rule).to eq('atLeast')
    end
  end

  describe 'Round-trip serialization' do
    let(:serializer) { Uniword::Serialization::OoxmlSerializer.new }
    let(:deserializer) { Uniword::Serialization::OoxmlDeserializer.new }

    it 'preserves exact line spacing through round-trip' do
      doc1 = Uniword::Document.new
      para1 = doc1.add_paragraph('Test')
      para1.line_spacing = { rule: 'exact', value: 240 }

      xml = serializer.serialize(doc1)
      doc2 = deserializer.deserialize(xml)
      para2 = doc2.paragraphs.first

      expect(para2.properties.line_spacing).to eq(240.0)
      expect(para2.properties.line_rule).to eq('exact')
    end

    it 'preserves multiple line spacing through round-trip' do
      doc1 = Uniword::Document.new
      para1 = doc1.add_paragraph('Test')
      para1.line_spacing = 1.5

      xml = serializer.serialize(doc1)
      doc2 = deserializer.deserialize(xml)
      para2 = doc2.paragraphs.first

      expect(para2.properties.line_spacing).to eq(1.5)
      expect(para2.properties.line_rule).to eq('auto')
    end

    it 'preserves "at least" line spacing through round-trip' do
      doc1 = Uniword::Document.new
      para1 = doc1.add_paragraph('Test')
      para1.line_spacing = { rule: 'atLeast', value: 280 }

      xml = serializer.serialize(doc1)
      doc2 = deserializer.deserialize(xml)
      para2 = doc2.paragraphs.first

      expect(para2.properties.line_spacing).to eq(280.0)
      expect(para2.properties.line_rule).to eq('atLeast')
    end
  end
end
