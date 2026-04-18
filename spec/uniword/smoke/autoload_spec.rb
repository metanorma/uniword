# frozen_string_literal: true

# Smoke tests: verify that every autoloaded module and class
# can be loaded without errors. These don't test behavior —
# they catch broken require paths, missing dependencies, and
# syntax errors across the entire codebase.
RSpec.describe "Autoload smoke tests" do
  # Resolve a dotted constant path like "Uniword::Ooxml" to the module/class
  def resolve(path)
    path.split("::").reduce(Object) { |mod, name| mod.const_get(name) }
  end

  # Top-level namespace modules
  {
    Ooxml: "Uniword::Ooxml",
    Docx: "Uniword::Docx",
    Properties: "Uniword::Properties",
    Wordprocessingml: "Uniword::Wordprocessingml",
    WpDrawing: "Uniword::WpDrawing",
    Drawingml: "Uniword::Drawingml",
    Vml: "Uniword::Vml",
    VmlWord: "Uniword::VmlWord",
    Math: "Uniword::Math",
    SharedTypes: "Uniword::SharedTypes",
    Template: "Uniword::Template",
    Visitor: "Uniword::Visitor",
    Validators: "Uniword::Validators",
    Stylesets: "Uniword::Stylesets",
    Infrastructure: "Uniword::Infrastructure",
    Accessibility: "Uniword::Accessibility",
    Assembly: "Uniword::Assembly",
    Batch: "Uniword::Batch",
    Metadata: "Uniword::Metadata",
    Quality: "Uniword::Quality",
    Schema: "Uniword::Schema",
    Configuration: "Uniword::Configuration",
    Transformation: "Uniword::Transformation",
    Validation: "Uniword::Validation",
    Warnings: "Uniword::Warnings",
    Mhtml: "Uniword::Mhtml",
    Themes: "Uniword::Themes",
    Resource: "Uniword::Resource",
    ContentTypes: "Uniword::ContentTypes",
    Glossary: "Uniword::Glossary",
    Office: "Uniword::Office",
    Presentationml: "Uniword::Presentationml",
    Spreadsheetml: "Uniword::Spreadsheetml",
    VmlOffice: "Uniword::VmlOffice",
    Wordprocessingml2010: "Uniword::Wordprocessingml2010",
    Wordprocessingml2013: "Uniword::Wordprocessingml2013",
    Wordprocessingml2016: "Uniword::Wordprocessingml2016",
    Customxml: "Uniword::Customxml",
    Builder: "Uniword::Builder",
  }.each do |name, const_path|
    describe name do
      it "autoloads without error" do
        expect { resolve(const_path) }.not_to raise_error
      end
    end
  end

  # Key classes that must be loadable
  {
    "DocumentFactory" => "Uniword::DocumentFactory",
    "DocumentWriter" => "Uniword::DocumentWriter",
    "FormatDetector" => "Uniword::FormatDetector",
    "ElementRegistry" => "Uniword::ElementRegistry",
    "HtmlImporter" => "Uniword::HtmlImporter",
    "CLI" => "Uniword::CLI",
    "StreamingParser" => "Uniword::StreamingParser",
    "VERSION" => "Uniword::VERSION",
  }.each do |name, const_path|
    describe name do
      it "autoloads without error" do
        expect { resolve(const_path) }.not_to raise_error
      end
    end
  end

  # Error classes
  {
    "Error" => "Uniword::Error",
    "FileNotFoundError" => "Uniword::FileNotFoundError",
    "InvalidFormatError" => "Uniword::InvalidFormatError",
    "CorruptedFileError" => "Uniword::CorruptedFileError",
    "ValidationError" => "Uniword::ValidationError",
    "ReadOnlyError" => "Uniword::ReadOnlyError",
    "DependencyError" => "Uniword::DependencyError",
    "UnsupportedOperationError" => "Uniword::UnsupportedOperationError",
    "ConversionError" => "Uniword::ConversionError",
  }.each do |name, const_path|
    describe name do
      it "autoloads without error" do
        expect { resolve(const_path) }.not_to raise_error
      end
    end
  end
end
