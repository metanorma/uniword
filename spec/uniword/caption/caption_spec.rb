# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Caption::Counter do
  it "starts at 1 and increments per label" do
    expect(described_class.new.next_value("Figure")).to eq(1)
    counter = described_class.new
    counter.next_value("Figure")
    expect(counter.next_value("Figure")).to eq(2)
  end

  it "tracks labels independently" do
    counter = described_class.new
    counter.next_value("Figure")
    counter.next_value("Figure")
    expect(counter.next_value("Table")).to eq(1)
    expect(counter.current("Figure")).to eq(2)
  end

  it "reset with no argument clears all labels" do
    counter = described_class.new
    counter.next_value("Figure")
    counter.reset
    expect(counter.next_value("Figure")).to eq(1)
  end

  it "reset with a label clears only that label" do
    counter = described_class.new
    counter.next_value("Figure")
    counter.next_value("Table")
    counter.reset("Figure")
    expect(counter.current("Figure")).to eq(0)
    expect(counter.current("Table")).to eq(1)
  end

  it "lists all tracked labels" do
    counter = described_class.new
    counter.next_value("Figure")
    counter.next_value("Table")
    expect(counter.labels).to contain_exactly("Figure", "Table")
  end
end

RSpec.describe Uniword::Caption::CaptionBuilder do
  let(:counter) { Uniword::Caption::Counter.new }
  let(:builder) { described_class.new(counter) }

  it "builds a caption paragraph with SEQ field and bookmark" do
    paragraph, bookmark_name = builder.build(label: "Figure",
                                             text: "Pipeline overview")
    expect(paragraph).to be_a(Uniword::Wordprocessingml::Paragraph)
    expect(bookmark_name).to eq("_Figure1")
  end

  it "uses Caption style" do
    paragraph, _name = builder.build(label: "Figure", text: "x")
    expect(paragraph.properties.style.value).to eq("Caption")
  end

  it "wraps the paragraph in a bookmark" do
    paragraph, name = builder.build(label: "Figure", text: "x")
    expect(paragraph.bookmark_starts.first.name).to eq(name)
    expect(paragraph.bookmark_ends).not_to be_empty
  end

  it "increments the counter on each call" do
    builder.build(label: "Figure", text: "first")
    _paragraph, name = builder.build(label: "Figure", text: "second")
    expect(name).to eq("_Figure2")
  end

  it "embeds a SEQ field with the label name" do
    paragraph, _name = builder.build(label: "Figure", text: "x")
    runs = paragraph.runs
    seq_field = runs.find { |r| r.is_a?(Uniword::Wordprocessingml::SimpleField) }
    expect(seq_field).not_to be_nil
    expect(seq_field.instr).to include("SEQ Figure")
  end

  it "honors a custom separator" do
    paragraph, _name = builder.build(label: "Figure",
                                     text: "x",
                                     separator: " - ")
    last_run = paragraph.runs.last
    expect(last_run.text.first.content).to include(" - x")
  end
end

RSpec.describe Uniword::Caption::CrossReference do
  it "builds a SimpleField with REF instruction" do
    field = described_class.new("_Figure1").build
    expect(field).to be_a(Uniword::Wordprocessingml::SimpleField)
    expect(field.instr).to include("REF _Figure1")
    expect(field.instr).to include("\\h")
  end
end

RSpec.describe "DocumentRoot caption API" do
  it "adds a caption and returns the bookmark name" do
    doc = Uniword::Wordprocessingml::DocumentRoot.new
    doc.body = Uniword::Wordprocessingml::Body.new
    name = doc.add_caption(label: "Figure", text: "Pipeline")
    expect(name).to eq("_Figure1")
    expect(doc.body.paragraphs.length).to eq(1)
  end

  it "increments across calls" do
    doc = Uniword::Wordprocessingml::DocumentRoot.new
    doc.body = Uniword::Wordprocessingml::Body.new
    doc.add_caption(label: "Figure", text: "one")
    name2 = doc.add_caption(label: "Figure", text: "two")
    expect(name2).to eq("_Figure2")
  end

  it "builds a cross-reference to a known bookmark" do
    doc = Uniword::Wordprocessingml::DocumentRoot.new
    field = doc.cross_reference_to("_Figure1")
    expect(field).to be_a(Uniword::Wordprocessingml::SimpleField)
    expect(field.instr).to include("REF _Figure1")
  end

  it "counter persists on the document across calls" do
    doc = Uniword::Wordprocessingml::DocumentRoot.new
    expect(doc.caption_counter).to equal(doc.caption_counter)
  end
end
