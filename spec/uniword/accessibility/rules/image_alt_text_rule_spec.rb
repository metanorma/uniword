# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Accessibility::Rules::ImageAltTextRule do
  subject(:rule) { described_class.new(config) }

  let(:config) do
    {
      wcag_criterion: "1.1.1 Non-text Content",
      level: "A",
      enabled: true,
      severity: :error,
      check_quality: true,
      min_length: 10,
      max_length: 150,
      suggestion: "Add descriptive alternative text",
    }
  end

  # Alt text for a w:drawing lives in wp:docPr/@descr. Build the documents by
  # parsing real OOXML so the rule is exercised against the drawings that
  # DocumentRoot#images actually returns.
  def document_with(*bodies)
    Uniword::Wordprocessingml::DocumentRoot.from_xml(<<~XML)
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <w:document
        xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
        xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
        xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
        xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
        xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">
        <w:body>#{bodies.join}</w:body>
      </w:document>
    XML
  end

  # A w:p holding one inline drawing. Pass alt_text: nil to omit @descr, which
  # is how Word writes a picture that has no alternative text at all.
  def drawing_paragraph(alt_text, id: 1)
    descr = alt_text.nil? ? "" : %( descr="#{alt_text}")
    <<~XML
      <w:p><w:r><w:drawing><wp:inline>
        <wp:extent cx="1000" cy="1000"/>
        <wp:docPr id="#{id}" name="Picture #{id}"#{descr}/>
        <a:graphic><a:graphicData
          uri="http://schemas.openxmlformats.org/drawingml/2006/picture">
          <pic:pic><pic:blipFill><a:blip r:embed="rId#{id}"/></pic:blipFill></pic:pic>
        </a:graphicData></a:graphic>
      </wp:inline></w:drawing></w:r></w:p>
    XML
  end

  def document_with_alt_texts(*alt_texts)
    paragraphs = alt_texts.each_with_index.map do |alt_text, index|
      drawing_paragraph(alt_text, id: index + 1)
    end
    document_with(*paragraphs)
  end

  describe "#check" do
    context "with no images" do
      let(:document) do
        document_with("<w:p><w:r><w:t>No pictures here</w:t></w:r></w:p>")
      end

      it "returns no violations" do
        expect(rule.check(document)).to be_empty
      end
    end

    context "with image missing alt text" do
      let(:document) { document_with_alt_texts(nil) }

      it "returns violation" do
        violations = rule.check(document)
        expect(violations.count).to eq(1)
      end

      it "creates error violation" do
        violation = rule.check(document).first
        expect(violation.severity).to eq(:error)
      end

      it "includes helpful message" do
        violation = rule.check(document).first
        expect(violation.message).to include("Image 1 missing alternative text")
      end

      it "includes suggestion" do
        violation = rule.check(document).first
        expect(violation.suggestion).to include("descriptive alternative text")
      end

      it "reports the offending drawing as the element" do
        violation = rule.check(document).first
        expect(violation.element).to be_a(Uniword::Wordprocessingml::Drawing)
      end
    end

    context "with alt text padded by whitespace" do
      # Padding is not description. If extract_alt_text returned the raw
      # attribute, the length checks would measure the padding and a
      # 3-character description would satisfy min_length: 10.
      let(:document) { document_with_alt_texts("        img        ") }

      it "measures the stripped length, not the padding" do
        violation = rule.check(document).first

        expect(violation.message).to include("too short")
        expect(violation.message).to include("3 chars")
      end
    end

    context "with image having empty alt text" do
      let(:document) { document_with_alt_texts("   ") }

      it "returns violation" do
        violations = rule.check(document)
        expect(violations.count).to eq(1)
      end
    end

    context "with valid alt text" do
      let(:document) do
        document_with_alt_texts("A beautiful sunset over mountains")
      end

      it "returns no violations" do
        expect(rule.check(document)).to be_empty
      end
    end

    context "with an anchored drawing" do
      def anchored_document(descr)
        attr = descr.nil? ? "" : %( descr="#{descr}")
        document_with(<<~XML)
          <w:p><w:r><w:drawing><wp:anchor>
            <wp:extent cx="1000" cy="1000"/>
            <wp:docPr id="1" name="Picture 1"#{attr}/>
          </wp:anchor></w:drawing></w:r></w:p>
        XML
      end

      it "reads alt text from the anchor's docPr" do
        document = anchored_document("A chart of quarterly revenue")

        expect(rule.check(document)).to be_empty
      end

      it "reports missing alt text when the anchor has no descr" do
        violation = rule.check(anchored_document(nil)).first

        expect(violation.message).to include("Image 1 missing alternative text")
      end
    end

    # CT_Drawing is a choice over wp:inline and wp:anchor with maxOccurs
    # unbounded, so a drawing carrying both is schema-valid.
    context "with a drawing carrying both inline and anchor" do
      def both_frames_document(inline_attr)
        document_with(<<~XML)
          <w:p><w:r><w:drawing>
            <wp:inline>
              <wp:docPr id="1" name="Picture 1"#{inline_attr}/>
            </wp:inline>
            <wp:anchor>
              <wp:docPr id="2" name="Picture 2" descr="A revenue chart"/>
            </wp:anchor>
          </w:drawing></w:r></w:p>
        XML
      end

      it "falls back to the anchor when the inline docPr has no descr" do
        expect(rule.check(both_frames_document(""))).to be_empty
      end

      # A blank descr is truthy in Ruby, so a naive || chain stops here and
      # reports missing alt text despite the anchor carrying a real one.
      it "falls back to the anchor when the inline descr is blank" do
        expect(rule.check(both_frames_document(%( descr="")))).to be_empty
      end
    end

    context "when check_quality is enabled" do
      context "with alt text too short" do
        let(:document) { document_with_alt_texts("Logo") }

        it "returns warning violation" do
          violations = rule.check(document)
          expect(violations.count).to eq(1)
          expect(violations.first.severity).to eq(:warning)
        end

        it "mentions length in message" do
          violation = rule.check(document).first
          expect(violation.message).to include("too short")
          expect(violation.message).to include("4 chars")
        end
      end

      context "with alt text too long" do
        let(:document) { document_with_alt_texts("a" * 200) }

        it "returns warning violation" do
          violations = rule.check(document)
          expect(violations.count).to eq(1)
          expect(violations.first.severity).to eq(:warning)
        end

        it "mentions length in message" do
          violation = rule.check(document).first
          expect(violation.message).to include("too long")
        end
      end

      context "with generic alt text" do
        [
          "image",
          "picture",
          "photo",
          "IMAGE",
          "image of sunset",
          "picture of",
        ].each do |generic_text|
          context "with '#{generic_text}'" do
            let(:document) { document_with_alt_texts(generic_text) }

            it "returns warning for generic text" do
              violations = rule.check(document)
              expect(violations.any? do |v|
                v.message.include?("generic")
              end).to be true
            end
          end
        end
      end

      context "with good alt text" do
        let(:document) do
          document_with_alt_texts("Company logo showing blue mountain")
        end

        it "returns no violations" do
          expect(rule.check(document)).to be_empty
        end
      end
    end

    context "when check_quality is disabled" do
      let(:config_no_quality) { config.merge(check_quality: false) }
      let(:rule_no_quality) { described_class.new(config_no_quality) }
      let(:document) { document_with_alt_texts("Logo") }

      it "does not check quality" do
        violations = rule_no_quality.check(document)
        expect(violations).to be_empty
      end
    end

    context "with multiple images" do
      let(:document) do
        document_with_alt_texts(nil, "Valid description here", "img")
      end

      it "checks all images" do
        violations = rule.check(document)
        expect(violations.count).to be >= 1
      end

      it "reports correct image numbers" do
        violations = rule.check(document)
        messages = violations.map(&:message).join(" ")
        expect(messages).to include("Image 1")
        expect(messages).to include("Image 3")
      end
    end
  end

  describe "#enabled?" do
    it "returns true when enabled" do
      expect(rule.enabled?).to be true
    end

    context "when disabled in config" do
      let(:config) { super().merge(enabled: false) }

      it "returns false" do
        expect(rule.enabled?).to be false
      end
    end
  end
end
