# frozen_string_literal: true

require "spec_helper"

RSpec.describe "StyleSet Integration" do
  # Skip if submodule not available (e.g., in CI without SSH access)
  before(:all) do
    skip "Submodule spec/fixtures/uniword-private not available" unless File.exist?("spec/fixtures/uniword-private/word-resources/quick-styles/Distinctive.dotx")
  end

  let(:dotx_file) { "spec/fixtures/uniword-private/word-resources/quick-styles/Distinctive.dotx" }

  describe "Loading StyleSets from .dotx files" do
    it "loads Distinctive.dotx successfully" do
      styleset = Uniword::StyleSet.from_dotx(dotx_file)

      expect(styleset).to be_a(Uniword::StyleSet)
      expect(styleset.name).to eq("Distinctive")
      expect(styleset.styles).to be_an(Array)
      expect(styleset.styles.count).to be > 0
    end

    it "parses paragraph properties from styles" do
      styleset = Uniword::StyleSet.from_dotx(dotx_file)
      styles_with_pPr = styleset.styles.select(&:paragraph_properties)

      expect(styles_with_pPr.count).to be > 0

      # Verify properties are actual objects
      styles_with_pPr.each do |style|
        expect(style.paragraph_properties).to be_a(Uniword::Wordprocessingml::ParagraphProperties)
      end
    end

    it "parses run properties from styles" do
      styleset = Uniword::StyleSet.from_dotx(dotx_file)
      styles_with_rPr = styleset.styles.select(&:run_properties)

      expect(styles_with_rPr.count).to be > 0

      # Verify properties are actual objects
      styles_with_rPr.each do |style|
        expect(style.run_properties).to be_a(Uniword::Wordprocessingml::RunProperties)
      end
    end

    it "parses specific property values correctly" do
      styleset = Uniword::StyleSet.from_dotx(dotx_file)
      heading1 = styleset.styles.find { |s| s.id == "Heading1" }

      expect(heading1).not_to be_nil
      expect(heading1.paragraph_properties).not_to be_nil
      expect(heading1.run_properties).not_to be_nil

      # Check paragraph properties
      pPr = heading1.paragraph_properties
      expect(pPr.spacing.before).to eq(300) if pPr.spacing
      expect(pPr.outline_level.value).to eq(0) if pPr.outline_level

      # Check run properties
      rPr = heading1.run_properties
      expect(rPr.size.value).to eq(32) if rPr.size
    end
  end

  describe "Applying StyleSets to documents" do
    it "applies StyleSet to document successfully" do
      styleset = Uniword::StyleSet.from_dotx(dotx_file)
      doc = Uniword::Wordprocessingml::DocumentRoot.new

      expect { styleset.apply_to(doc) }.not_to raise_error
      expect(doc.styles_configuration.styles.count).to eq(styleset.styles.count)
    end

    it "merges StyleSet with existing styles using :keep_existing strategy" do
      styleset = Uniword::StyleSet.from_dotx(dotx_file)
      doc = Uniword::Wordprocessingml::DocumentRoot.new

      # Document already has default Normal style
      initial_count = doc.styles_configuration.styles.count

      styleset.apply_to(doc, strategy: :keep_existing)

      # Should have more styles but keep existing ones
      expect(doc.styles_configuration.styles.count).to be >= initial_count
    end

    it "replaces existing styles with :replace strategy" do
      styleset = Uniword::StyleSet.from_dotx(dotx_file)
      doc = Uniword::Wordprocessingml::DocumentRoot.new

      # Add a custom Normal style (use styleId: not id: for lutaml-model)
      custom_normal = Uniword::Wordprocessingml::Style.new(styleId: "Normal",
                                                           name: "Custom Normal", type: "paragraph")
      doc.styles_configuration.add_style(custom_normal, allow_overwrite: true)

      styleset.apply_to(doc, strategy: :replace)

      # Normal from StyleSet should replace custom one
      normal_style = doc.styles_configuration.styles.find { |s| s.id == "Normal" }
      expect(normal_style.name).not_to eq("Custom Normal")
    end
  end

  describe "Serializing StyleSet-enhanced documents" do
    it "serializes styles.xml with parsed properties" do
      styleset = Uniword::StyleSet.from_dotx(dotx_file)
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      styleset.apply_to(doc)

      styles_xml = doc.styles_configuration.to_xml(prefix: true)

      expect(styles_xml).to include("<w:style")
      expect(styles_xml).to include('styleId="Normal"')
      expect(styles_xml).to include('styleId="Heading1"')
      expect(styles_xml).to include("<w:pPr>")
      expect(styles_xml).to include("<w:rPr>")
    end

    it "preserves property values in serialized XML" do
      styleset = Uniword::StyleSet.from_dotx(dotx_file)
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      styleset.apply_to(doc)

      styles_xml = doc.styles_configuration.to_xml(prefix: true)

      # Check for specific property serialization
      expect(styles_xml).to include("<w:spacing")  # Spacing properties
      expect(styles_xml).to include("<w:sz")       # Font size
      expect(styles_xml).to include("<w:outlineLvl") # Outline level for headings
    end
  end

  describe "Integration with Document API" do
    it "allows shorthand StyleSet application" do
      doc = Uniword::Wordprocessingml::DocumentRoot.new

      # This would use bundled YAML StyleSets
      expect { doc.apply_styleset("distinctive") }.not_to raise_error
    end
  end

  describe "Performance" do
    it "loads and applies StyleSet in under 1 second" do
      start_time = Time.now

      styleset = Uniword::StyleSet.from_dotx(dotx_file)
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      styleset.apply_to(doc)

      elapsed = Time.now - start_time

      expect(elapsed).to be < 1.0
    end
  end
end
