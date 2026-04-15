# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Template::VariableResolver do
  describe "#resolve" do
    context "with hash data" do
      let(:data) { { title: "Test Title", count: 42 } }
      let(:resolver) { described_class.new(data) }

      it "resolves simple variables" do
        expect(resolver.resolve("title")).to eq("Test Title")
        expect(resolver.resolve("count")).to eq(42)
      end

      it "returns nil for undefined variables" do
        expect(resolver.resolve("undefined")).to be_nil
      end

      it "handles nested hash access" do
        nested_data = { chapter: { number: "5.1", title: "Scope" } }
        nested_resolver = described_class.new(nested_data)

        expect(nested_resolver.resolve("chapter.number")).to eq("5.1")
        expect(nested_resolver.resolve("chapter.title")).to eq("Scope")
      end
    end

    context "with object data" do
      let(:data_class) do
        Struct.new(:title, :number) do
          def subtitle
            "Chapter #{number}"
          end
        end
      end
      let(:data) { data_class.new("Test", "5.1") }
      let(:resolver) { described_class.new(data) }

      it "resolves object properties" do
        expect(resolver.resolve("title")).to eq("Test")
        expect(resolver.resolve("number")).to eq("5.1")
      end

      it "resolves object methods" do
        expect(resolver.resolve("subtitle")).to eq("Chapter 5.1")
      end
    end

    it "handles nil and empty expressions" do
      resolver = described_class.new({})
      expect(resolver.resolve(nil)).to be_nil
      expect(resolver.resolve("")).to be_nil
    end
  end

  describe "#evaluate" do
    let(:data) { { count: 10, status: "active", enabled: true } }
    let(:resolver) { described_class.new(data) }

    it "evaluates simple truthiness" do
      expect(resolver.evaluate("enabled")).to be true
      expect(resolver.evaluate("status")).to be true
    end

    it "evaluates equality comparisons" do
      expect(resolver.evaluate("count == 10")).to be true
      expect(resolver.evaluate("count == 5")).to be false
      expect(resolver.evaluate('status == "active"')).to be true
    end

    it "evaluates inequality comparisons" do
      expect(resolver.evaluate("count != 5")).to be true
      expect(resolver.evaluate("count != 10")).to be false
    end

    it "evaluates numeric comparisons" do
      expect(resolver.evaluate("count > 5")).to be true
      expect(resolver.evaluate("count < 5")).to be false
      expect(resolver.evaluate("count >= 10")).to be true
      expect(resolver.evaluate("count <= 10")).to be true
    end

    it "returns false for invalid conditions" do
      expect(resolver.evaluate("invalid syntax !!!")).to be false
    end

    it "handles nil and empty conditions" do
      expect(resolver.evaluate(nil)).to be false
      expect(resolver.evaluate("")).to be false
    end
  end
end
