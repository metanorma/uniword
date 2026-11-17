# frozen_string_literal: true

require "spec_helper"
require "tmpdir"

# Another gem loaded into the process can overwrite lutaml's process-
# global XML adapter at its own first-parse time (plurimath#588: the mml
# chain writes :ox). Uniword's public entry points re-assert the adapter
# boot resolved, so a mid-process flip cannot corrupt round trips.
RSpec.describe "Uniword.ensure_adapter!" do
  let(:fixture_path) do
    path = File.join(Dir.mktmpdir, "adapter_guard_input.docx")
    Uniword::Builder::DocumentBuilder.new.tap do |builder|
      builder.paragraph("Adapter flip guard")
    end.build.save(path)
    path
  end

  after do
    Lutaml::Model::Config.xml_adapter_type = Uniword::UNIWORD_XML_ADAPTER
  end

  it "restores the boot adapter when a foreign gem flips it" do
    Lutaml::Model::Config.xml_adapter_type = :ox
    expect(Lutaml::Model::Config.xml_adapter_type).to eq(:ox)

    Uniword.ensure_adapter!
    expect(Lutaml::Model::Config.xml_adapter_type)
      .to eq(Uniword::UNIWORD_XML_ADAPTER)
  end

  it "round-trips correctly after a foreign adapter flip" do
    Lutaml::Model::Config.xml_adapter_type = :ox

    out_path = File.join(Dir.mktmpdir, "flip_roundtrip.docx")
    doc = Uniword::DocumentFactory.from_file(fixture_path)
    doc.save(out_path)
    reloaded = Uniword::DocumentFactory.from_file(out_path)

    expect(reloaded.body.paragraphs.first.text).to eq("Adapter flip guard")
  end
end
