# frozen_string_literal: true

require "spec_helper"
require "uniword/builder"

RSpec.describe Uniword::Builder do
  describe ".text" do
    it "creates a Run with plain text" do
      run = described_class.text("Hello")
      expect(run).to be_a(Uniword::Wordprocessingml::Run)
      expect(run.text.to_s).to eq("Hello")
      expect(run.properties).to be_nil
    end

    it "creates a Run with bold formatting" do
      run = described_class.text("Bold", bold: true)
      expect(run.properties.bold).to be_a(Uniword::Properties::Bold)
    end

    it "creates a Run with italic formatting" do
      run = described_class.text("Italic", italic: true)
      expect(run.properties.italic).to be_a(Uniword::Properties::Italic)
    end

    it "creates a Run with underline formatting" do
      run = described_class.text("Underlined", underline: true)
      expect(run.properties.underline).to be_a(Uniword::Properties::Underline)
    end

    it "creates a Run with color" do
      run = described_class.text("Colored", color: "FF0000")
      expect(run.properties.color).to be_a(Uniword::Properties::ColorValue)
    end

    it "creates a Run with font size" do
      run = described_class.text("Sized", size: 14)
      expect(run.properties.size.value).to eq(28) # 14 * 2
    end

    it "creates a Run with font name" do
      run = described_class.text("Fonted", font: "Arial")
      expect(run.properties.font).to eq("Arial")
    end

    it "creates a Run with multiple formatting options" do
      run = described_class.text("Styled", bold: true, italic: true, color: "0000FF", size: 12)
      expect(run.properties.bold).not_to be_nil
      expect(run.properties.italic).not_to be_nil
      expect(run.properties.color).not_to be_nil
      expect(run.properties.size).not_to be_nil
    end
  end

  describe ".hyperlink" do
    it "creates a Hyperlink without text" do
      hl = described_class.hyperlink("https://example.com")
      expect(hl).to be_a(Uniword::Wordprocessingml::Hyperlink)
      expect(hl.target).to eq("https://example.com")
      expect(hl.runs).to be_empty
    end

    it "creates a Hyperlink with text" do
      hl = described_class.hyperlink("https://example.com", "Click here")
      expect(hl.runs.size).to eq(1)
      expect(hl.runs.first.text.to_s).to eq("Click here")
    end

    it "creates a Hyperlink with blue text by default" do
      hl = described_class.hyperlink("https://example.com", "Link")
      run = hl.runs.first
      expect(run.properties.color.value).to eq("0000FF")
    end
  end

  describe ".tab_stop" do
    it "creates a TabStop with position and alignment" do
      tab = described_class.tab_stop(position: 7200, alignment: :right)
      expect(tab).to be_a(Uniword::Properties::TabStop)
      expect(tab.position).to eq(7200)
      expect(tab.alignment).to eq("right")
    end

    it "creates a TabStop with leader" do
      tab = described_class.tab_stop(position: 3600, alignment: :decimal, leader: "dot")
      expect(tab.leader).to eq("dot")
    end
  end

  describe ".page_break" do
    it "creates a Run with a page break" do
      run = described_class.page_break
      expect(run).to be_a(Uniword::Wordprocessingml::Run)
      expect(run.break).to be_a(Uniword::Wordprocessingml::Break)
      expect(run.break.type).to eq("page")
    end
  end

  describe ".tab" do
    it "creates a Run with a tab character" do
      run = described_class.tab
      expect(run).to be_a(Uniword::Wordprocessingml::Run)
      expect(run.tab).to be_a(Uniword::Wordprocessingml::Tab)
    end
  end
end
