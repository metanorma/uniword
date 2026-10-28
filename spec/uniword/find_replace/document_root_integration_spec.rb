# frozen_string_literal: true

require "spec_helper"

RSpec.describe "DocumentRoot#find_replace" do
  def build_doc(*paragraphs)
    b = Uniword::Builder::DocumentBuilder.new
    paragraphs.each { |text| b.paragraph(text) }
    b.model
  end

  it "replaces matches across all scopes by default" do
    doc = build_doc("Hello foo world", "Another foo here")
    result = doc.find_replace("foo", "bar")
    expect(result.count).to eq(2)
  end

  it "returns a FindReplace::Result" do
    doc = build_doc("Hello foo world")
    expect(doc.find_replace("foo", "bar"))
      .to be_a(Uniword::FindReplace::Result)
  end

  it "supports regex pattern with capture" do
    doc = build_doc("Chapter 1")
    doc.find_replace(/Chapter (\d+)/, 'Ch. \1')
    expect(doc.body.paragraphs.first.text).to eq("Ch. 1")
  end

  it "accepts a single scope symbol" do
    doc = build_doc("Hello foo world")
    result = doc.find_replace("foo", "bar", scope: :body)
    expect(result.by_scope.keys).to eq([:body])
  end

  it "accepts an array of scopes" do
    doc = build_doc("Hello foo world")
    result = doc.find_replace("foo", "bar", scope: %i[body headers])
    expect(result.by_scope.keys).to contain_exactly(:body, :headers)
  end

  it "supports ignore_case for plain-string match" do
    doc = build_doc("FOO Foo fOo")
    result = doc.find_replace("foo", "bar", ignore_case: true)
    expect(result.count).to eq(3)
    expect(doc.body.paragraphs.first.text).to eq("bar bar bar")
  end

  it "does not fail on a document with empty body" do
    doc = Uniword::Wordprocessingml::DocumentRoot.new
    doc.body = Uniword::Wordprocessingml::Body.new
    expect { doc.find_replace("foo", "bar") }.not_to raise_error
  end
end
