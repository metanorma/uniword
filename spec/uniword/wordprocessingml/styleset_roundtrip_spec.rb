# frozen_string_literal: true

require "spec_helper"
require "canon"

RSpec.describe "StyleSet Round-Trip Fidelity (Open-Source YAML)" do
  Uniword::Stylesets::YamlStyleSetLoader.available_stylesets.each do |name|
    describe name do
      let(:styleset) { Uniword::Stylesets::YamlStyleSetLoader.load_bundled(name) }

      it "loads successfully from YAML" do
        expect(styleset).to be_a(Uniword::StyleSet)
        expect(styleset.name).not_to be_nil
      end

      it "contains styles" do
        expect(styleset.styles).to be_an(Array)
        expect(styleset.styles.count).to be > 0
      end

      it "round-trips styles through XML serialization" do
        original_count = styleset.styles.count
        reparsed_count = 0

        styleset.styles.each do |style|
          xml = style.to_xml(prefix: true)
          reparsed = Uniword::Wordprocessingml::Style.from_xml(xml)
          reparsed_count += 1 if reparsed
        rescue StandardError
        end

        expect(reparsed_count).to eq(original_count)
      end

      context "paragraph properties" do
        let(:heading1) { styleset.styles.find { |s| s.id == "Heading1" } }

        it "preserves spacing" do
          skip "Heading1 not found" unless heading1
          skip "No paragraph properties" unless heading1.paragraph_properties

          original = Array(heading1.paragraph_properties.spacing)
          skip "No spacing" if original.empty?

          xml = heading1.to_xml(prefix: true)
          reparsed = Uniword::Wordprocessingml::Style.from_xml(xml)
          roundtripped = Array(reparsed.paragraph_properties.spacing)

          expect(roundtripped.size).to eq(original.size)
          expect(roundtripped.map(&:before)).to eq(original.map(&:before))
          expect(roundtripped.map(&:after)).to eq(original.map(&:after))
        end
      end

      context "run properties" do
        let(:heading1) { styleset.styles.find { |s| s.id == "Heading1" } }

        it "preserves font size" do
          skip "Heading1 not found" unless heading1
          skip "No run properties" unless heading1.run_properties
          skip "No size" unless heading1.run_properties.size

          original = heading1.run_properties.size
          xml = heading1.to_xml(prefix: true)
          reparsed = Uniword::Wordprocessingml::Style.from_xml(xml)

          expect(reparsed.run_properties.size).to eq(original)
        end
      end
    end
  end
end

RSpec.describe "StyleSet Round-Trip Fidelity (Binary .dotx)" do
  before(:all) do
    skip "Submodule spec/fixtures/uniword-private not available" unless Dir.glob("spec/fixtures/uniword-private/word-resources/quick-styles/*.dotx").any?
  end

  %w[quick-styles].each do |dir_name|
    describe "#{dir_name}/" do
      Dir.glob("spec/fixtures/uniword-private/word-resources/#{dir_name}/*.dotx").each do |styleset_file|
        styleset_name = File.basename(styleset_file, ".dotx")

        describe styleset_name do
          let(:styleset) { Uniword::StyleSet.from_dotx(styleset_file) }

          it "loads successfully" do
            expect(styleset).to be_a(Uniword::StyleSet)
            expect(styleset.name).not_to be_nil
          end

          it "loads styles" do
            expect(styleset.styles).to be_an(Array)
            expect(styleset.styles.count).to be > 0
          end

          it "preserves style count in round-trip" do
            original_count = styleset.styles.count

            reparsed_count = 0
            styleset.styles.each do |style|
              xml = style.to_xml(prefix: true)
              reparsed = Uniword::Wordprocessingml::Style.from_xml(xml)
              reparsed_count += 1 if reparsed
            rescue StandardError
            end

            expect(reparsed_count).to eq(original_count)
          end

          context "paragraph properties" do
            let(:heading1) { styleset.styles.find { |s| s.id == "Heading1" } }

            it "preserves spacing" do
              skip "Heading1 not found" unless heading1
              skip "No paragraph properties" unless heading1.paragraph_properties

              original = Array(heading1.paragraph_properties.spacing)
              skip "No spacing" if original.empty?

              xml = heading1.to_xml(prefix: true)
              reparsed = Uniword::Wordprocessingml::Style.from_xml(xml)
              roundtripped = Array(reparsed.paragraph_properties.spacing)

              expect(roundtripped.size).to eq(original.size)
              expect(roundtripped.map(&:before)).to eq(original.map(&:before))
              expect(roundtripped.map(&:after)).to eq(original.map(&:after))
            end

            it "preserves alignment" do
              skip "Heading1 not found" unless heading1
              skip "No paragraph properties" unless heading1.paragraph_properties

              original = heading1.paragraph_properties.alignment
              xml = heading1.to_xml(prefix: true)
              reparsed = Uniword::Wordprocessingml::Style.from_xml(xml)

              expect(reparsed.paragraph_properties.alignment).to eq(original)
            end
          end

          context "run properties" do
            let(:heading1) { styleset.styles.find { |s| s.id == "Heading1" } }

            it "preserves font size" do
              skip "Heading1 not found" unless heading1
              skip "No run properties" unless heading1.run_properties
              skip "No size" unless heading1.run_properties.size

              original = heading1.run_properties.size
              xml = heading1.to_xml(prefix: true)
              reparsed = Uniword::Wordprocessingml::Style.from_xml(xml)

              expect(reparsed.run_properties.size).to eq(original)
            end

            it "preserves small caps" do
              skip "Heading1 not found" unless heading1
              skip "No run properties" unless heading1.run_properties

              original = heading1.run_properties.small_caps
              xml = heading1.to_xml(prefix: true)
              reparsed = Uniword::Wordprocessingml::Style.from_xml(xml)

              expect(reparsed.run_properties.small_caps).to eq(original)
            end
          end
        end
      end
    end
  end

  after(:all) do
    Dir.glob("spec/fixtures/uniword-private/word-resources/quick-styles/*.dotx").count
  end

  # Word emits two w:spacing elements in one w:pPr in Modern.dotx, which is
  # why ParagraphProperties#spacing is a collection. Keep both.
  describe "repeated w:spacing in a single w:pPr" do
    let(:file) do
      "spec/fixtures/uniword-private/word-resources/quick-styles/Modern.dotx"
    end
    let(:style) do
      skip "Modern.dotx not available" unless File.exist?(file)
      Uniword::StyleSet.from_dotx(file).styles.find { |s| s.id == "NoSpacing" }
    end
    let(:fields) do
      ->(list) { list.map { |s| [s.before, s.after, s.line, s.line_rule] } }
    end

    it "keeps both entries when loading" do
      expect(style.paragraph_properties.spacing.size).to eq(2)
    end

    it "keeps both entries through an XML round-trip" do
      reparsed = Uniword::Wordprocessingml::Style.from_xml(
        style.to_xml(prefix: true),
      )

      expect(fields.call(reparsed.paragraph_properties.spacing))
        .to eq(fields.call(style.paragraph_properties.spacing))
    end
  end
end
