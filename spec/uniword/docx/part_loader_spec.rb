# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Docx::PartLoader do
  let(:fixture) { "spec/fixtures/docx_gem/basic.docx" }

  describe ".loader_for" do
    it "returns the strategy registered under a key" do
      expect(described_class.loader_for(:xml_model))
        .to be_a(described_class::XmlModelLoader)
    end

    it "raises ArgumentError for unknown keys" do
      expect { described_class.loader_for(:no_such_loader) }
        .to raise_error(ArgumentError, /unknown part loader/)
    end
  end

  describe ".register_loader" do
    it "adds a strategy without editing the loop (open/closed)" do
      strategy = Class.new { def load(_context, _definition); end }.new
      described_class.register_loader(:probe, strategy)

      expect(described_class.loader_for(:probe)).to eq(strategy)
    end
  end

  describe ".load" do
    subject(:package) { Uniword::Docx::Package.from_file(fixture) }

    it "loads the document and its configurations" do
      loaded = [package.document, package.styles, package.settings,
                package.font_table, package.web_settings]

      expect(loaded).to all(be_a(Lutaml::Model::Serializable))
    end

    it "loads the content types and rels parts" do
      loaded = [package.content_types, package.package_rels,
                package.document_rels]

      expect(loaded).to all(be_a(Lutaml::Model::Serializable))
    end

    it "loads header and footer parts in order" do
      kinds = package.document.header_footer_parts.map(&:kind)

      expect(kinds).to eq(%i[header header footer footer])
    end

    it "keeps loaded relationship ids on header and footer parts" do
      parts = package.document.header_footer_parts.to_a

      expect(parts.map(&:r_id)).to all(match(/\ArId\d+\z/))
    end

    it "flags header and footer parts as loaded" do
      parts = package.document.header_footer_parts.to_a

      expect(parts).to all(be_loaded)
    end

    it "parses header and footer content models" do
      parts = package.document.header_footer_parts.to_a

      expect(parts.map { |part| part.content.class }.uniq)
        .to contain_exactly(Uniword::Wordprocessingml::Header,
                            Uniword::Wordprocessingml::Footer)
    end
  end
end
