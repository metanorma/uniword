# frozen_string_literal: true

require "spec_helper"
require "uniword/builder"

RSpec.describe "Line Spacing (RAW OOXML Values)" do
  describe "ParagraphBuilder#spacing" do
    let(:doc) { Uniword::Wordprocessingml::DocumentRoot.new }
    let(:para) do
      p = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: "Test paragraph")
      p.runs << run
      doc.body.paragraphs << p
      p
    end

    context "with numeric value (RAW OOXML twips)" do
      it "sets line spacing as raw twips value" do
        para.properties ||= Uniword::Wordprocessingml::ParagraphProperties.new
        para.properties.spacing ||= Uniword::Properties::Spacing.new
        para.properties.spacing.line = 360
        expect(para.properties&.spacing&.line).to eq(360)
      end

      it "sets line spacing with rule via ParagraphBuilder" do
        Uniword::Builder::ParagraphBuilder.new(para).spacing(line: 240,
                                                             rule: "exact")
        expect(para.properties.spacing.line).to eq(240)
        expect(para.properties.spacing.line_rule).to eq("exact")
      end

      it "sets line spacing with auto rule" do
        Uniword::Builder::ParagraphBuilder.new(para).spacing(line: 360,
                                                             rule: "auto")
        expect(para.properties.spacing.line).to eq(360)
        expect(para.properties.spacing.line_rule).to eq("auto")
      end
    end

    context "with hash format" do
      it "sets exact line spacing" do
        Uniword::Builder::ParagraphBuilder.new(para).spacing(line: 240,
                                                             rule: "exact")
        expect(para.properties.spacing.line).to eq(240)
        expect(para.properties.spacing.line_rule).to eq("exact")
      end

      it 'sets "at least" line spacing' do
        Uniword::Builder::ParagraphBuilder.new(para).spacing(line: 280,
                                                             rule: "atLeast")
        expect(para.properties.spacing.line).to eq(280)
        expect(para.properties.spacing.line_rule).to eq("atLeast")
      end

      it "handles string keys" do
        Uniword::Builder::ParagraphBuilder.new(para).spacing(line: 240,
                                                             rule: "exact")
        expect(para.properties.spacing.line).to eq(240)
        expect(para.properties.spacing.line_rule).to eq("exact")
      end
    end
  end

  describe "Paragraph line spacing getter" do
    let(:doc) { Uniword::Wordprocessingml::DocumentRoot.new }
    let(:para) do
      p = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: "Test paragraph")
      p.runs << run
      doc.body.paragraphs << p
      p
    end

    it "returns raw integer value (twips)" do
      para.properties ||= Uniword::Wordprocessingml::ParagraphProperties.new
      para.properties.spacing ||= Uniword::Properties::Spacing.new
      para.properties.spacing.line = 360
      expect(para.properties&.spacing&.line).to eq(360)
    end

    it "returns nil when not set" do
      expect(para.properties&.spacing&.line).to be_nil
    end
  end

  describe "OOXML serialization" do
    let(:doc) { Uniword::Wordprocessingml::DocumentRoot.new }

    it "serializes exact line spacing correctly" do
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: "Test")
      para.runs << run
      Uniword::Builder::ParagraphBuilder.new(para).spacing(line: 240,
                                                           rule: "exact")
      doc.body.paragraphs << para

      xml = doc.to_xml(prefix: true)
      expect(xml).to include('w:lineRule="exact"')
      expect(xml).to include('w:line="240"')
    end

    it "serializes auto line spacing correctly" do
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: "Test")
      para.runs << run
      Uniword::Builder::ParagraphBuilder.new(para).spacing(line: 360,
                                                           rule: "auto")
      doc.body.paragraphs << para

      xml = doc.to_xml(prefix: true)
      expect(xml).to include('w:lineRule="auto"')
      expect(xml).to include('w:line="360"')
    end

    it 'serializes "at least" line spacing correctly' do
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: "Test")
      para.runs << run
      Uniword::Builder::ParagraphBuilder.new(para).spacing(line: 280,
                                                           rule: "atLeast")
      doc.body.paragraphs << para

      xml = doc.to_xml(prefix: true)
      expect(xml).to include('w:lineRule="atLeast"')
      expect(xml).to include('w:line="280"')
    end
  end

  describe "OOXML deserialization" do
    it "deserializes exact line spacing" do
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
      expect(para.properties.spacing.line_rule).to eq("exact")
    end

    it "deserializes auto line spacing" do
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
      expect(para.properties.spacing.line_rule).to eq("auto")
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
      expect(para.properties.spacing.line_rule).to eq("atLeast")
    end
  end

  describe "Round-trip serialization" do
    it "preserves exact line spacing through round-trip" do
      doc1 = Uniword::Wordprocessingml::DocumentRoot.new
      para1 = Uniword::Wordprocessingml::Paragraph.new
      run1 = Uniword::Wordprocessingml::Run.new(text: "Test")
      para1.runs << run1
      Uniword::Builder::ParagraphBuilder.new(para1).spacing(line: 240,
                                                            rule: "exact")
      doc1.body.paragraphs << para1

      xml = doc1.to_xml(prefix: true)
      doc2 = Uniword::Wordprocessingml::DocumentRoot.from_xml(xml)
      para2 = doc2.body.paragraphs.first

      expect(para2.properties.spacing.line).to eq(240)
      expect(para2.properties.spacing.line_rule).to eq("exact")
    end

    it "preserves auto line spacing through round-trip" do
      doc1 = Uniword::Wordprocessingml::DocumentRoot.new
      para1 = Uniword::Wordprocessingml::Paragraph.new
      run1 = Uniword::Wordprocessingml::Run.new(text: "Test")
      para1.runs << run1
      Uniword::Builder::ParagraphBuilder.new(para1).spacing(line: 360,
                                                            rule: "auto")
      doc1.body.paragraphs << para1

      xml = doc1.to_xml(prefix: true)
      doc2 = Uniword::Wordprocessingml::DocumentRoot.from_xml(xml)
      para2 = doc2.body.paragraphs.first

      expect(para2.properties.spacing.line).to eq(360)
      expect(para2.properties.spacing.line_rule).to eq("auto")
    end

    it 'preserves "at least" line spacing through round-trip' do
      doc1 = Uniword::Wordprocessingml::DocumentRoot.new
      para1 = Uniword::Wordprocessingml::Paragraph.new
      run1 = Uniword::Wordprocessingml::Run.new(text: "Test")
      para1.runs << run1
      Uniword::Builder::ParagraphBuilder.new(para1).spacing(line: 280,
                                                            rule: "atLeast")
      doc1.body.paragraphs << para1

      xml = doc1.to_xml(prefix: true)
      doc2 = Uniword::Wordprocessingml::DocumentRoot.from_xml(xml)
      para2 = doc2.body.paragraphs.first

      expect(para2.properties.spacing.line).to eq(280)
      expect(para2.properties.spacing.line_rule).to eq("atLeast")
    end
  end
end
