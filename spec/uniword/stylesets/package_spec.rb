# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Stylesets::Package do
  # Skip if submodule not available (e.g., in CI without SSH access)
  before(:all) do
    skip "Submodule spec/fixtures/uniword-private not available" unless File.exist?("spec/fixtures/uniword-private/word-resources/quick-styles/Distinctive.dotx")
  end

  let(:dotx_path) do
    "spec/fixtures/uniword-private/word-resources/quick-styles/Distinctive.dotx"
  end

  describe ".from_file" do
    context "with valid .dotx file" do
      it "loads package from .dotx file" do
        pkg = described_class.from_file(dotx_path)
        expect(pkg).to be_a(described_class)
        expect(pkg.styles_configuration).to be_a(Uniword::Wordprocessingml::StylesConfiguration)
        expect(pkg.source_path).to eq(dotx_path)
      end

      it "deserializes styles.xml into StylesConfiguration" do
        pkg = described_class.from_file(dotx_path)
        expect(pkg.styles_configuration.styles).to be_an(Array)
        expect(pkg.styles_configuration.styles.count).to be > 0
      end
    end

    context "with missing file" do
      it "raises FileNotFoundError" do
        expect do
          described_class.from_file("nonexistent.dotx")
        end.to raise_error(Uniword::FileNotFoundError, /File not found/)
      end
    end

    context "with corrupt ZIP file" do
      it "raises CorruptedFileError" do
        # Create a non-ZIP file
        temp_file = Tempfile.new(["corrupt", ".dotx"])
        temp_file.write("not a zip file")
        temp_file.close

        expect do
          described_class.from_file(temp_file.path)
        end.to raise_error(Uniword::CorruptedFileError, /Failed to extract/)

        temp_file.unlink
      end
    end
  end

  describe "#styleset" do
    let(:package) { described_class.from_file(dotx_path) }

    it "converts to StyleSet" do
      styleset = package.styleset

      expect(styleset).to be_a(Uniword::StyleSet)
      expect(styleset.name).to eq("Distinctive")
      expect(styleset.styles).to be_an(Array)
      expect(styleset.styles.count).to be > 0
      expect(styleset.source_file).to eq(dotx_path)
    end

    it "extracts name from filename" do
      styleset = package.styleset
      expect(styleset.name).to eq("Distinctive")
    end
  end

  describe "#extract_name" do
    it "converts filename to title case" do
      pkg = described_class.new(source_path: "/path/to/distinctive_modern.dotx")
      expect(pkg.send(:extract_name)).to eq("Distinctive Modern")
    end

    it "handles single word filenames" do
      pkg = described_class.new(source_path: "/path/to/formal.dotx")
      expect(pkg.send(:extract_name)).to eq("Formal")
    end

    it "returns default name when no source_path" do
      pkg = described_class.new
      expect(pkg.send(:extract_name)).to eq("Custom StyleSet")
    end
  end
end
