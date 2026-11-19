# frozen_string_literal: true

require "spec_helper"
require "tmpdir"

# Uniword's entry points pin the boot adapter for the duration of the
# operation and restore the caller's value on return. lutaml's adapter
# setting is process-global: a bare re-assert (1.7.10) permanently
# overwrote a host-configured adapter for the rest of the process -
# metanorma pins :nokogiri for its collection Config serialization, and
# the clobber turned that lane onto the leptris adapter, reformatted its
# inline XML, and red metanorma's collection.doc Word suite.
RSpec.describe "Uniword.with_boot_adapter" do
  let(:fixture_path) do
    path = File.join(Dir.mktmpdir, "adapter_scope_input.docx")
    Uniword::Builder::DocumentBuilder.new.tap do |builder|
      builder.paragraph("Adapter scope guard")
    end.build.save(path)
    path
  end

  after do
    Lutaml::Model::Config.xml_adapter_type = Uniword::UNIWORD_XML_ADAPTER
  end

  it "restores the host adapter after from_file returns" do
    Lutaml::Model::Config.xml_adapter_type = :nokogiri

    Uniword::DocumentFactory.from_file(fixture_path)

    expect(Lutaml::Model::Config.xml_adapter_type).to eq(:nokogiri)
  end

  it "restores the host adapter after DocumentRoot#save returns" do
    Lutaml::Model::Config.xml_adapter_type = :nokogiri

    out_path = File.join(Dir.mktmpdir, "adapter_scope_output.docx")
    doc = Uniword::DocumentFactory.from_file(fixture_path)
    doc.save(out_path)

    expect(Lutaml::Model::Config.xml_adapter_type).to eq(:nokogiri)
  end

  it "restores the host adapter when the entry point raises" do
    Lutaml::Model::Config.xml_adapter_type = :nokogiri

    expect do
      Uniword::DocumentFactory.from_file(
        File.join(Dir.mktmpdir, "missing.docx"),
      )
    end.to raise_error(Uniword::FileNotFoundError)

    expect(Lutaml::Model::Config.xml_adapter_type).to eq(:nokogiri)
  end

  it "still serializes with the boot adapter inside the operation" do
    Lutaml::Model::Config.xml_adapter_type = :ox

    out_path = File.join(Dir.mktmpdir, "scope_roundtrip.docx")
    doc = Uniword::DocumentFactory.from_file(fixture_path)
    doc.save(out_path)
    reloaded = Uniword::DocumentFactory.from_file(out_path)

    expect(reloaded.body.paragraphs.first.text).to eq("Adapter scope guard")
    # the foreign :ox write is left untouched outside the operation
    expect(Lutaml::Model::Config.xml_adapter_type).to eq(:ox)
  end
end
