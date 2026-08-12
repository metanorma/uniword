# frozen_string_literal: true

require "spec_helper"

# Both builder methods took a documented Boolean and threw it away — the
# parameter was named `_value` and the toggle was always constructed bare,
# which ST_OnOff reads as ON. So `lock(false)` produced a locked control and
# `showing_placeholder(false)` produced a placeholder, each the opposite of
# what the caller asked for.
RSpec.describe Uniword::Builder::SdtBuilder do
  subject(:builder) { described_class.new }

  def sdt_pr_xml
    builder.build.properties.to_xml
  end

  describe "#lock" do
    it "writes a bare w:temporary when locked" do
      builder.lock(true)

      expect(sdt_pr_xml).to match(%r{<(w:)?temporary\s*/>})
    end

    it "writes w:val=\"false\" when explicitly not locked" do
      builder.lock(false)

      expect(sdt_pr_xml).to match(/val="false"/)
    end

    it "defaults to locked" do
      builder.lock

      expect(builder.properties.temporary.on?).to be(true)
    end

    it "round-trips the value it was given" do
      expect([true, false].map { |v| described_class.new.lock(v).properties.temporary.on? })
        .to eq([true, false])
    end
  end

  describe "#showing_placeholder" do
    it "writes a bare w:showingPlcHdr when shown" do
      builder.showing_placeholder(true)

      expect(sdt_pr_xml).to match(%r{<(w:)?showingPlcHdr\s*/>})
    end

    it "writes w:val=\"false\" when explicitly not shown" do
      builder.showing_placeholder(false)

      expect(sdt_pr_xml).to match(/val="false"/)
    end

    it "defaults to shown" do
      builder.showing_placeholder

      expect(builder.properties.showing_placeholder_header.on?).to be(true)
    end

    it "round-trips the value it was given" do
      expect([true, false].map do |v|
        described_class.new.showing_placeholder(v).properties
          .showing_placeholder_header.on?
      end).to eq([true, false])
    end
  end

  # The renderer is the consumer that actually acted on the wrong reading.
  describe "through the mhtml renderer" do
    it "does not emit the flags a caller explicitly turned off" do
      props = described_class.new.lock(false).showing_placeholder(false)
        .build.properties
      html = Uniword::Transformation::MhtmlElementRenderer.new
        .send(:build_sdt_attrs, props)

      expect(html).not_to include("temporary")
      expect(html).not_to include("showingPlcHdr")
    end

    it "emits both flags a caller turned on" do
      props = described_class.new.lock(true).showing_placeholder(true)
        .build.properties
      html = Uniword::Transformation::MhtmlElementRenderer.new
        .send(:build_sdt_attrs, props)

      expect(html).to include('w:temporary="t"')
      expect(html).to include('w:showingPlcHdr="t"')
    end
  end
end
