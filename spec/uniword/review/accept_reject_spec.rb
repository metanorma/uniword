# frozen_string_literal: true

require "spec_helper"
require "uniword/review"

RSpec.describe Uniword::Review::AcceptReject do
  let(:handler) { described_class.new }

  describe "#accept" do
    it "accepts an insertion" do
      revision = Uniword::Revision.new(
        type: :insert,
        author: "Alice",
        text: "New text",
      )

      result = handler.accept(revision)
      expect(result).to be(true)
      expect(revision.type).to eq(:accepted)
    end

    it "accepts a deletion (removes content)" do
      revision = Uniword::Revision.new(
        type: :delete,
        author: "Alice",
        text: "Old text",
      )

      result = handler.accept(revision)
      expect(result).to be(true)
      expect(revision.type).to eq(:accepted)
      expect(revision.content).to be_nil
    end

    it "accepts a format change" do
      revision = Uniword::Revision.new(
        type: :format_change,
        author: "Alice",
        content: "Changed to bold",
      )

      result = handler.accept(revision)
      expect(result).to be(true)
      expect(revision.type).to eq(:accepted)
    end

    it "raises for unknown type" do
      revision = Uniword::Revision.new(author: "Alice")
      revision.type = :unknown

      expect { handler.accept(revision) }.to raise_error(
        ArgumentError, /Unknown revision type/
      )
    end
  end

  describe "#reject" do
    it "rejects an insertion (removes content)" do
      revision = Uniword::Revision.new(
        type: :insert,
        author: "Alice",
        text: "New text",
      )

      result = handler.reject(revision)
      expect(result).to be(true)
      expect(revision.type).to eq(:rejected)
      expect(revision.content).to be_nil
    end

    it "rejects a deletion (keeps content)" do
      revision = Uniword::Revision.new(
        type: :delete,
        author: "Alice",
        text: "Old text",
      )

      result = handler.reject(revision)
      expect(result).to be(true)
      expect(revision.type).to eq(:rejected)
    end

    it "rejects a format change" do
      revision = Uniword::Revision.new(
        type: :format_change,
        author: "Alice",
        content: "Changed to bold",
      )

      result = handler.reject(revision)
      expect(result).to be(true)
      expect(revision.type).to eq(:rejected)
      expect(revision.content).to be_nil
    end

    it "raises for unknown type" do
      revision = Uniword::Revision.new(author: "Alice")
      revision.type = :unknown

      expect { handler.reject(revision) }.to raise_error(
        ArgumentError, /Unknown revision type/
      )
    end
  end
end
