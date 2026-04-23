# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Theme Extraction and Reuse" do
  let(:test_docx_path) { "spec/fixtures/test_themed.docx" }

  describe Uniword::Drawingml::Theme do
    it "can be created programmatically" do
      theme = Uniword::Drawingml::Theme.new(name: "Corporate")
      theme.color_scheme[:accent1] = "0066CC"
      theme.font_scheme.major_font = "Helvetica"

      expect(theme.name).to eq("Corporate")
      expect(theme.color(:accent1)).to eq("0066CC")
      expect(theme.major_font).to eq("Helvetica")
    end

    it "can be duplicated" do
      theme = Uniword::Drawingml::Theme.new(name: "Original")
      theme.color_scheme[:accent1] = "0066CC"
      theme.font_scheme.major_font = "Helvetica"

      duplicated = theme.dup

      expect(duplicated.name).to eq("Original")
      expect(duplicated.color(:accent1)).to eq("0066CC")
      expect(duplicated.major_font).to eq("Helvetica")
      expect(duplicated).not_to be(theme)
    end

    it "validates correctly" do
      valid_theme = Uniword::Drawingml::Theme.new(name: "Valid")
      expect(valid_theme.valid?).to be true

      invalid_theme = Uniword::Drawingml::Theme.new(name: "")
      expect(invalid_theme.valid?).to be false
    end
  end

  describe Uniword::Drawingml::ColorScheme do
    it "has default Office theme colors" do
      scheme = Uniword::Drawingml::ColorScheme.new

      expect(scheme[:dk1]).to eq("000000")
      expect(scheme[:lt1]).to eq("FFFFFF")
      expect(scheme[:accent1]).to eq("4472C4")
    end

    it "allows custom colors" do
      scheme = Uniword::Drawingml::ColorScheme.new
      scheme[:accent1] = "FF0000"

      expect(scheme[:accent1]).to eq("FF0000")
      expect(scheme.has_color?(:accent1)).to be true
    end

    it "can be duplicated" do
      scheme = Uniword::Drawingml::ColorScheme.new
      scheme[:accent1] = "FF0000"

      duplicated = scheme.dup

      expect(duplicated[:accent1]).to eq("FF0000")
      expect(duplicated).not_to be(scheme)
    end
  end

  describe Uniword::Drawingml::FontScheme do
    it "has default Office theme fonts" do
      scheme = Uniword::Drawingml::FontScheme.new

      expect(scheme.major_font).to eq("Calibri Light")
      expect(scheme.minor_font).to eq("Calibri")
    end

    it "allows custom fonts" do
      scheme = Uniword::Drawingml::FontScheme.new
      scheme.major_font = "Helvetica"
      scheme.minor_font = "Arial"

      expect(scheme.major_font).to eq("Helvetica")
      expect(scheme.minor_font).to eq("Arial")
    end

    it "can be duplicated" do
      scheme = Uniword::Drawingml::FontScheme.new
      scheme.major_font = "Helvetica"

      duplicated = scheme.dup

      expect(duplicated.major_font).to eq("Helvetica")
      expect(duplicated).not_to be(scheme)
    end
  end

  describe Uniword::Wordprocessingml::DocumentRoot do
    describe "#theme" do
      it "can have a theme assigned" do
        doc = Uniword::Wordprocessingml::DocumentRoot.new
        theme = Uniword::Drawingml::Theme.new(name: "Corporate")

        doc.theme = theme

        expect(doc.theme).to eq(theme)
        expect(doc.theme.name).to eq("Corporate")
      end

      it "starts with no theme" do
        doc = Uniword::Wordprocessingml::DocumentRoot.new
        expect(doc.theme).to be_nil
      end
    end

    describe "#apply_theme_from" do
      it "applies theme from source document" do
        # Create source document with theme
        source = Uniword::Wordprocessingml::DocumentRoot.new
        source.theme = Uniword::Drawingml::Theme.new(name: "Source Theme")
        source.theme.color_scheme.colors[:accent1] = "FF0000"
        source_path = "spec/fixtures/temp_source.docx"
        source.save(source_path)

        # Apply theme to new document
        doc = Uniword::Wordprocessingml::DocumentRoot.new
        doc.apply_theme_from(source_path)

        expect(doc.theme).not_to be_nil
        expect(doc.theme.name).to eq("Source Theme")
        expect(doc.theme.color(:accent1)).to eq("FF0000")

        # Cleanup
        safe_rm_f(source_path)
      end
    end

    describe "#apply_styles_from" do
      it "applies styles from source document with conflict resolution" do
        # Create source with custom style
        source = Uniword::Wordprocessingml::DocumentRoot.new
        source.styles_configuration.create_paragraph_style(
          "CustomStyle",
          "Custom Style"
        )
        source_path = "spec/fixtures/temp_source_styles.docx"
        source.save(source_path)

        # Apply to new document
        doc = Uniword::Wordprocessingml::DocumentRoot.new
        doc.apply_styles_from(source_path)

        expect(doc.styles_configuration.style_by_id("CustomStyle")).not_to be_nil

        # Cleanup
        safe_rm_f(source_path)
      end
    end

    describe "#apply_template" do
      it "applies both theme and styles from template" do
        # Create template
        template = Uniword::Wordprocessingml::DocumentRoot.new
        template.theme = Uniword::Drawingml::Theme.new(name: "Template Theme")
        template.styles_configuration.create_paragraph_style(
          "TemplateStyle",
          "Template Style"
        )
        template_path = "spec/fixtures/temp_template.docx"
        template.save(template_path)

        # Apply template
        doc = Uniword::Wordprocessingml::DocumentRoot.new
        doc.apply_template(template_path)

        expect(doc.theme.name).to eq("Template Theme")
        expect(doc.styles_configuration.style_by_id("TemplateStyle")).not_to be_nil

        # Cleanup
        safe_rm_f(template_path)
      end
    end
  end

  describe Uniword::Wordprocessingml::StylesConfiguration do
    describe "#import_from_document" do
      it "imports styles from another document" do
        source = Uniword::Wordprocessingml::DocumentRoot.new
        source.styles_configuration.create_paragraph_style("Imported", "Imported")

        target = Uniword::Wordprocessingml::DocumentRoot.new
        target.styles_configuration.import_from_document(source)

        expect(target.styles_configuration.style_by_id("Imported")).not_to be_nil
      end

      it "skips existing styles" do
        source = Uniword::Wordprocessingml::DocumentRoot.new
        source.styles_configuration.create_paragraph_style("Existing", "Existing")

        target = Uniword::Wordprocessingml::DocumentRoot.new
        target.styles_configuration.create_paragraph_style(
          "Existing",
          "Original"
        )
        target.styles_configuration.import_from_document(source)

        expect(target.styles_configuration.style_by_id("Existing").name).to eq("Original")
      end
    end

    describe "#export_styles" do
      it "exports all styles as copies" do
        config = Uniword::Wordprocessingml::StylesConfiguration.new
        config.create_paragraph_style("Export1", "Export 1")
        config.create_paragraph_style("Export2", "Export 2")

        exported = config.export_styles

        expect(exported.length).to be > 0
        expect(exported.first).to be_a(Uniword::Wordprocessingml::Style)
      end
    end

    describe "#merge" do
      it "keeps existing styles by default" do
        target = Uniword::Wordprocessingml::StylesConfiguration.new
        target.create_paragraph_style("Conflict", "Original")

        source = Uniword::Wordprocessingml::StylesConfiguration.new
        source.create_paragraph_style("Conflict", "Updated")
        source.create_paragraph_style("New", "New Style")

        target.merge(source)

        expect(target.style_by_id("Conflict").name).to eq("Original")
        expect(target.style_by_id("New")).not_to be_nil
      end

      it "replaces existing styles when requested" do
        target = Uniword::Wordprocessingml::StylesConfiguration.new
        target.create_paragraph_style("Conflict", "Original")

        source = Uniword::Wordprocessingml::StylesConfiguration.new
        source.create_paragraph_style("Conflict", "Updated")

        target.merge(source, conflict_resolution: :replace)

        expect(target.style_by_id("Conflict").name).to eq("Updated")
      end

      it "renames conflicting styles when requested" do
        target = Uniword::Wordprocessingml::StylesConfiguration.new
        target.create_paragraph_style("Conflict", "Original")

        source = Uniword::Wordprocessingml::StylesConfiguration.new
        source.create_paragraph_style("Conflict", "Updated")

        target.merge(source, conflict_resolution: :rename)

        expect(target.style_by_id("Conflict").name).to eq("Original")
        expect(target.style_by_id("Conflict_imported")).not_to be_nil
      end

      it "raises error for invalid conflict resolution" do
        target = Uniword::Wordprocessingml::StylesConfiguration.new
        source = Uniword::Wordprocessingml::StylesConfiguration.new

        expect do
          target.merge(source, conflict_resolution: :invalid)
        end.to raise_error(ArgumentError)
      end
    end

    describe "#style_exists?" do
      it "checks if style exists by ID" do
        config = Uniword::Wordprocessingml::StylesConfiguration.new
        config.create_paragraph_style("Exists", "Exists")

        expect(config.style_exists?("Exists")).to be true
        expect(config.style_exists?("DoesNotExist")).to be false
      end
    end

    describe "#find_by_id" do
      it "finds style by ID" do
        config = Uniword::Wordprocessingml::StylesConfiguration.new
        style = config.create_paragraph_style("FindMe", "Find Me")

        found = config.find_by_id("FindMe")

        expect(found).to eq(style)
      end
    end
  end

  describe "Theme serialization and deserialization" do
    it "round-trips theme through DOCX" do
      # Create document with theme
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      doc.theme = Uniword::Drawingml::Theme.new(name: "Round Trip Theme")
      doc.theme.color_scheme.colors[:accent1] = "0066CC"
      doc.theme.font_scheme.major_font = "Helvetica"

      # Add content
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: "Test content")
      para.runs << run
      doc.body.paragraphs << para

      # Save and reload
      path = "spec/fixtures/temp_theme_roundtrip.docx"
      doc.save(path)

      reloaded = Uniword.load(path)

      expect(reloaded.theme).not_to be_nil
      expect(reloaded.theme.name).to eq("Round Trip Theme")
      expect(reloaded.theme.color(:accent1)).to eq("0066CC")
      expect(reloaded.theme.major_font).to eq("Helvetica")

      # Cleanup
      safe_rm_f(path)
    end

    it "preserves theme when document has no explicit theme" do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: "No theme")
      para.runs << run
      doc.body.paragraphs << para

      path = "spec/fixtures/temp_no_theme.docx"
      doc.save(path)

      reloaded = Uniword.load(path)

      # Reconciler injects a default theme from the profile
      expect(reloaded.theme).not_to be_nil

      # Cleanup
      safe_rm_f(path)
    end
  end

  describe "Integration: Using theme colors in styles" do
    it "allows defining styles using theme colors" do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      doc.theme = Uniword::Drawingml::Theme.new(name: "Corporate")
      doc.theme.color_scheme.colors[:accent1] = "0066CC"
      doc.theme.font_scheme.major_font = "Helvetica"

      # Create style using theme color
      doc.styles_configuration.create_paragraph_style(
        "CorporateHeading",
        "Corporate Heading",
        run_properties: Uniword::Wordprocessingml::RunProperties.new(
          color: doc.theme.color(:accent1),
          font: doc.theme.major_font,
          bold: true,
          size: 32
        )
      )

      # Use the style - create paragraph with properties first
      heading = Uniword::Wordprocessingml::Paragraph.new(
        properties: Uniword::Wordprocessingml::ParagraphProperties.new(style: "CorporateHeading")
      )
      run = Uniword::Wordprocessingml::Run.new(text: "Corporate Heading")
      heading.runs << run
      doc.body.paragraphs << heading

      # Save and verify
      path = "spec/fixtures/temp_themed_style.docx"
      doc.save(path)

      reloaded = Uniword.load(path)
      style = reloaded.styles_configuration.style_by_id("CorporateHeading")

      expect(style).not_to be_nil
      expect(style.run_properties.color).to eq("0066CC")
      expect(style.run_properties.font).to eq("Helvetica")

      # Cleanup
      safe_rm_f(path)
    end
  end
end
