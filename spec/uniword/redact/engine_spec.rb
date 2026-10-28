# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Redact::PatternLibrary do
  it "includes default PII patterns" do
    names = described_class.all.map(&:name)
    expect(names).to include(:ssn, :email, :phone, :credit_card, :ipv4)
  end

  it "selects :all patterns when given :all" do
    expect(described_class.select(:all).length)
      .to eq(described_class.all.length)
  end

  it "selects specific patterns by name" do
    selected = described_class.select(%i[ssn email])
    expect(selected.map(&:name)).to contain_exactly(:ssn, :email)
  end

  it "ignores unknown names" do
    expect(described_class.select([:unknown])).to eq([])
  end
end

RSpec.describe Uniword::Redact::Engine do
  let(:builder) do
    b = Uniword::Builder::DocumentBuilder.new
    b.paragraph("Call me at 555-555-1234 or email alice@example.com")
    b.paragraph("SSN: 123-45-6789")
    b
  end

  it "redacts default PII patterns" do
    result = described_class.new(document: builder.model).run
    expect(result.count).to be > 0
    expect(result.patterns_matched).to include(:phone, :email, :ssn)
  end

  it "replaces matches with [REDACTED]" do
    described_class.new(document: builder.model).run
    text = builder.model.body.paragraphs.map(&:text).join(" ")
    expect(text).not_to include("alice@example.com")
    expect(text).not_to include("555-555-1234")
    expect(text).not_to include("123-45-6789")
    expect(text).to include("[REDACTED]")
  end

  it "honors custom pattern selection" do
    result = described_class.new(document: builder.model,
                                 patterns: [:email]).run
    expect(result.patterns_matched).to eq([:email])
  end

  it "honors scope" do
    result = described_class.new(document: builder.model,
                                 patterns: :pii,
                                 scope: :headers).run
    expect(result.count).to eq(0)
  end

  it "uses custom replacement when pattern declares one" do
    pattern = Uniword::Redact::Pattern.new(name: :custom,
                                           regex: /SECRET/,
                                           replacement: "___")
    b = Uniword::Builder::DocumentBuilder.new
    b.paragraph("This is SECRET information")
    described_class.new(document: b.model, patterns: [pattern]).run
    expect(b.model.body.paragraphs.first.text).to include("___")
    expect(b.model.body.paragraphs.first.text).not_to include("SECRET")
  end
end

RSpec.describe "DocumentRoot#redact" do
  it "is reachable via the public API" do
    b = Uniword::Builder::DocumentBuilder.new
    b.paragraph("Email: test@example.com")
    result = b.model.redact
    expect(result).to be_a(Uniword::Redact::Result)
    expect(result.count).to be > 0
  end
end
