# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Wordprocessingml::TrackChanges do
  it "round-trips through XML" do
    element = described_class.new
    xml = element.to_xml
    expect(xml).to include("trackChanges")
  end
end

RSpec.describe "DocumentRoot track-changes API" do
  let(:doc) { Uniword::Wordprocessingml::DocumentRoot.new }

  it "starts with tracking off" do
    expect(doc.track_changes_enabled?).to be(false)
  end

  it "turns on" do
    doc.track_changes_on!
    expect(doc.track_changes_enabled?).to be(true)
    expect(doc.settings.track_changes)
      .to be_a(Uniword::Wordprocessingml::TrackChanges)
  end

  it "turns off after being on" do
    doc.track_changes_on!
    doc.track_changes_off!
    expect(doc.track_changes_enabled?).to be(false)
    expect(doc.settings.track_changes).to be_nil
  end

  it "creates settings on demand when turning on" do
    expect(doc.settings).to be_nil
    doc.track_changes_on!
    expect(doc.settings).to be_a(Uniword::Wordprocessingml::Settings)
  end

  it "emits trackChanges in settings XML" do
    doc.track_changes_on!
    settings_xml = doc.settings.to_xml
    expect(settings_xml).to include("trackChanges")
  end
end
