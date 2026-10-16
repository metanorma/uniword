# frozen_string_literal: true

require "spec_helper"

# ST_OnOff also appears as an XML attribute, not just as an element with a
# w:val. Those attributes went through a second reader that raised on any
# token outside the vocabulary, so one malformed attribute anywhere in
# styles.xml killed the parse of the whole part.
RSpec.describe "ST_OnOff attributes" do
  ns = 'xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"'

  spellings = { "1" => true, "true" => true, "on" => true,
                "0" => false, "false" => false, "off" => false,
                "banana" => true }.freeze

  describe Uniword::Wordprocessingml::Style do
    %w[default customStyle].each do |attr|
      spellings.each do |token, expected|
        it "reads w:#{attr}=#{token.inspect} as #{expected}" do
          style = described_class.from_xml(
            %(<w:style #{ns} w:type="paragraph" w:styleId="Normal" w:#{attr}="#{token}"/>),
          )

          expect(style.public_send(attr == "default" ? :default : :customStyle))
            .to be(expected)
        end
      end
    end
  end

  describe Uniword::Wordprocessingml::LatentStylesException do
    { "qFormat" => :q_format, "semiHidden" => :semi_hidden,
      "unhideWhenUsed" => :unhide_when_used, "locked" => :locked }
      .each do |attr, reader|
      spellings.each do |token, expected|
        it "reads w:#{attr}=#{token.inspect} as #{expected}" do
          exception = described_class.from_xml(
            %(<w:lsdException #{ns} w:name="Normal" w:#{attr}="#{token}"/>),
          )

          expect(exception.public_send(reader)).to be(expected)
        end
      end

      it "reads an absent w:#{attr} as nil" do
        exception = described_class.from_xml(
          %(<w:lsdException #{ns} w:name="Normal"/>),
        )

        expect(exception.public_send(reader)).to be_nil
      end
    end
  end

  describe Uniword::Wordprocessingml::LatentStyles do
    { "defQFormat" => :def_q_format, "defSemiHidden" => :def_semi_hidden,
      "defUnhideWhenUsed" => :def_unhide_when_used,
      "defLockedState" => :def_locked_state }.each do |attr, reader|
      spellings.each do |token, expected|
        it "reads w:#{attr}=#{token.inspect} as #{expected}" do
          latent = described_class.from_xml(
            %(<w:latentStyles #{ns} w:#{attr}="#{token}"/>),
          )

          expect(latent.public_send(reader)).to be(expected)
        end
      end
    end
  end

  # The point of not raising: a document with one bad token still parses, and
  # everything around it survives.
  it "parses a styles part that carries a malformed toggle" do
    xml = <<~XML
      <w:styles #{ns}>
        <w:latentStyles w:defQFormat="maybe" w:count="2">
          <w:lsdException w:name="Normal" w:qFormat="yes"/>
        </w:latentStyles>
        <w:style w:type="paragraph" w:styleId="Normal" w:default="perhaps">
          <w:name w:val="Normal"/>
        </w:style>
      </w:styles>
    XML

    config = nil
    expect { config = Uniword::Wordprocessingml::StylesConfiguration.from_xml(xml) }
      .not_to raise_error

    aggregate_failures do
      expect(config.styles.first.styleId).to eq("Normal")
      expect(config.styles.first.name.val).to eq("Normal")
      expect(config.styles.first.default).to be(true)
      expect(config.latent_styles.count).to eq(2)
      expect(config.latent_styles.def_q_format).to be(true)
      expect(config.latent_styles.lsd_exception.first.q_format).to be(true)
    end
  end
end
