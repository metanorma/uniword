# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Docx.js Compatibility: Run (Text Formatting)", :compatibility do
  describe "TextRun" do
    describe "constructor" do
      it "should add text into run" do
        run = Uniword::Run.new
        run.text = "test"

        expect(run.text).to eq("test")
        expect(run).to be_a(Uniword::Run)
      end

      it "should add empty text into run" do
        run = Uniword::Run.new
        run.text = ""

        expect(run.text).to eq("")
        expect(run).to be_a(Uniword::Run)
      end

      it "should create run with text in one step" do
        run = Uniword::Run.new.tap { |r| r.text = "Hello World" }

        expect(run.text).to eq("Hello World")
      end
    end

    describe "text formatting" do
      it "should support bold text" do
        run = Uniword::Run.new
        run.text = "Bold text"
        run.properties = Uniword::Properties::RunProperties.new(bold: true)

        expect(run.properties.bold).to be true
        expect(run.text).to eq("Bold text")
      end

      it "should support italic text" do
        run = Uniword::Run.new
        run.text = "Italic text"
        run.properties = Uniword::Properties::RunProperties.new(italic: true)

        expect(run.properties.italic).to be true
      end

      it "should support underline text" do
        run = Uniword::Run.new
        run.text = "Underlined text"
        run.properties = Uniword::Properties::RunProperties.new(underline: "single")

        expect(run.properties.underline).to eq("single")
      end

      it "should support strike-through text" do
        run = Uniword::Run.new
        run.text = "Strike text"
        run.properties = Uniword::Properties::RunProperties.new(strike: true)

        expect(run.properties.strike).to be true
      end

      it "should support double-strike text" do
        run = Uniword::Run.new
        run.text = "Double strike"
        run.properties = Uniword::Properties::RunProperties.new(double_strike: true)

        expect(run.properties.double_strike).to be true
      end

      it "should support all caps text" do
        run = Uniword::Run.new
        run.text = "all caps"
        run.properties = Uniword::Properties::RunProperties.new(all_caps: true)

        expect(run.properties.all_caps).to be true
      end

      it "should support small caps text" do
        run = Uniword::Run.new
        run.text = "small caps"
        run.properties = Uniword::Properties::RunProperties.new(small_caps: true)

        expect(run.properties.small_caps).to be true
      end

      it "should support multiple formatting properties" do
        run = Uniword::Run.new
        run.text = "Formatted"
        run.properties = Uniword::Properties::RunProperties.new(
          bold: true,
          italic: true,
          underline: "single"
        )

        expect(run.properties.bold).to be true
        expect(run.properties.italic).to be true
        expect(run.properties.underline).to eq("single")
      end
    end

    describe "size and color" do
      it "should support font size" do
        run = Uniword::Run.new
        run.text = "Sized text"
        run.properties = Uniword::Properties::RunProperties.new(size: 24)

        expect(run.properties.size).to eq(24)
      end

      it "should support text color" do
        run = Uniword::Run.new
        run.text = "Colored text"
        run.properties = Uniword::Properties::RunProperties.new(color: "FF0000")

        expect(run.properties.color).to eq("FF0000")
      end

      it "should support highlight color" do
        run = Uniword::Run.new
        run.text = "Highlighted"
        run.properties = Uniword::Properties::RunProperties.new(highlight: "yellow")

        expect(run.properties.highlight).to eq("yellow")
      end
    end
  end

  describe "RunFonts" do
    describe "constructor" do
      it "uses the font name for all font types" do
        run = Uniword::Run.new
        run.text = "Times font"
        run.properties = Uniword::Properties::RunProperties.new(font: "Times")

        expect(run.properties.font).to eq("Times")
      end

      it "supports specific font attributes" do
        run = Uniword::Run.new
        run.text = "Custom fonts"
        run.properties = Uniword::Properties::RunProperties.new(
          font: "Times",
          font_ascii: "Arial"
        )

        expect(run.properties.font).to eq("Times")
        expect(run.properties.font_ascii).to eq("Arial")
      end

      it "supports east asian font" do
        run = Uniword::Run.new
        run.text = "东亚字体"
        run.properties = Uniword::Properties::RunProperties.new(
          font: "Times",
          font_east_asia: "KaiTi"
        )

        expect(run.properties.font_east_asia).to eq("KaiTi")
      end
    end
  end

  describe "EmphasisMark" do
    describe "constructor" do
      it "should create emphasis mark with default dot" do
        run = Uniword::Run.new
        run.text = "Emphasized"
        run.properties = Uniword::Properties::RunProperties.new(emphasis_mark: "dot")

        expect(run.properties.emphasis_mark).to eq("dot")
      end

      it "should support dot emphasis mark" do
        run = Uniword::Run.new
        run.text = "Dot emphasis"
        run.properties = Uniword::Properties::RunProperties.new(emphasis_mark: "dot")

        expect(run.properties.emphasis_mark).to eq("dot")
      end

      it "should support comma emphasis mark" do
        run = Uniword::Run.new
        run.text = "Comma emphasis"
        run.properties = Uniword::Properties::RunProperties.new(emphasis_mark: "comma")

        expect(run.properties.emphasis_mark).to eq("comma")
      end

      it "should support circle emphasis mark" do
        run = Uniword::Run.new
        run.text = "Circle emphasis"
        run.properties = Uniword::Properties::RunProperties.new(emphasis_mark: "circle")

        expect(run.properties.emphasis_mark).to eq("circle")
      end

      it "should support under-dot emphasis mark" do
        run = Uniword::Run.new
        run.text = "Under-dot emphasis"
        run.properties = Uniword::Properties::RunProperties.new(emphasis_mark: "underDot")

        expect(run.properties.emphasis_mark).to eq("underDot")
      end
    end
  end

  describe "Language" do
    describe "createLanguageComponent" do
      it "should create a language component" do
        run = Uniword::Run.new
        run.text = "Multi-language"
        run.properties = Uniword::Properties::RunProperties.new(
          language: "en-US",
          language_east_asia: "zh-CN",
          language_bidi: "ar-SA"
        )

        expect(run.properties.language).to eq("en-US")
        expect(run.properties.language_east_asia).to eq("zh-CN")
        expect(run.properties.language_bidi).to eq("ar-SA")
      end

      it "should support simple language" do
        run = Uniword::Run.new
        run.text = "English"
        run.properties = Uniword::Properties::RunProperties.new(language: "en-US")

        expect(run.properties.language).to eq("en-US")
      end

      it "should support east asian language" do
        run = Uniword::Run.new
        run.text = "中文"
        run.properties = Uniword::Properties::RunProperties.new(language_east_asia: "zh-CN")

        expect(run.properties.language_east_asia).to eq("zh-CN")
      end

      it "should support bidirectional language" do
        run = Uniword::Run.new
        run.text = "عربي"
        run.properties = Uniword::Properties::RunProperties.new(language_bidi: "ar-SA")

        expect(run.properties.language_bidi).to eq("ar-SA")
      end
    end
  end

  describe "CharacterSpacing" do
    describe "constructor" do
      it "should create character spacing" do
        run = Uniword::Run.new
        run.text = "Spaced text"
        run.properties = Uniword::Properties::RunProperties.new(character_spacing: 32)

        expect(run.properties.character_spacing).to eq(32)
      end

      it "should support different spacing values" do
        run = Uniword::Run.new
        run.text = "Wide spacing"
        run.properties = Uniword::Properties::RunProperties.new(character_spacing: 100)

        expect(run.properties.character_spacing).to eq(100)
      end

      it "should support negative spacing" do
        run = Uniword::Run.new
        run.text = "Tight spacing"
        run.properties = Uniword::Properties::RunProperties.new(character_spacing: -20)

        expect(run.properties.character_spacing).to eq(-20)
      end
    end
  end

  describe "Color" do
    describe "constructor" do
      it "should create color without hash" do
        run = Uniword::Run.new
        run.text = "White text"
        run.properties = Uniword::Properties::RunProperties.new(color: "FFFFFF")

        expect(run.properties.color).to eq("FFFFFF")
      end

      it "should support hex colors" do
        run = Uniword::Run.new
        run.text = "Red text"
        run.properties = Uniword::Properties::RunProperties.new(color: "FF0000")

        expect(run.properties.color).to eq("FF0000")
      end

      it "should support various colors" do
        colors = ["000000", "FF0000", "00FF00", "0000FF", "FFFF00", "FF00FF", "00FFFF"]

        colors.each do |color|
          run = Uniword::Run.new
          run.text = "Colored"
          run.properties = Uniword::Properties::RunProperties.new(color: color)

          expect(run.properties.color).to eq(color)
        end
      end
    end
  end

  describe "integrated run creation" do
    it "should create fully formatted run" do
      run = Uniword::Run.new
      run.text = "Fully formatted text"
      run.properties = Uniword::Properties::RunProperties.new(
        bold: true,
        italic: true,
        underline: "single",
        size: 24,
        color: "FF0000",
        font: "Arial",
        language: "en-US"
      )

      expect(run.text).to eq("Fully formatted text")
      expect(run.properties.bold).to be true
      expect(run.properties.italic).to be true
      expect(run.properties.underline).to eq("single")
      expect(run.properties.size).to eq(24)
      expect(run.properties.color).to eq("FF0000")
      expect(run.properties.font).to eq("Arial")
      expect(run.properties.language).to eq("en-US")
    end

    it "should create run and add to paragraph" do
      para = Uniword::Paragraph.new
      run = Uniword::Run.new
      run.text = "In paragraph"
      run.properties = Uniword::Properties::RunProperties.new(bold: true)

      para.add_run(run)

      expect(para.runs.count).to eq(1)
      expect(para.runs.first.text).to eq("In paragraph")
      expect(para.runs.first.properties.bold).to be true
    end

    it "should support multiple runs in paragraph" do
      para = Uniword::Paragraph.new

      run1 = Uniword::Run.new
      run1.text = "Bold "
      run1.properties = Uniword::Properties::RunProperties.new(bold: true)

      run2 = Uniword::Run.new
      run2.text = "Italic "
      run2.properties = Uniword::Properties::RunProperties.new(italic: true)

      run3 = Uniword::Run.new
      run3.text = "Normal"

      para.add_run(run1)
      para.add_run(run2)
      para.add_run(run3)

      expect(para.runs.count).to eq(3)
      expect(para.runs[0].properties.bold).to be true
      expect(para.runs[1].properties.italic).to be true
      expect(para.runs[2].properties).to be_nil
    end
  end
end