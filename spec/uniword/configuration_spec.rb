# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Configuration do
  let(:config) { described_class.new }

  after do
    # Do not leak global configuration state between examples
    Uniword.configuration.reset!
  end

  describe "defaults" do
    it "defaults validate_on_save to true" do
      expect(config.validate_on_save).to be(true)
    end

    it "defaults xsd_validation to false" do
      expect(config.xsd_validation).to be(false)
    end

    it "defaults log_save_fixes to true" do
      expect(config.log_save_fixes).to be(true)
    end
  end

  describe "attribute writers" do
    it "round-trips validate_on_save" do
      config.validate_on_save = false
      expect(config.validate_on_save).to be(false)
    end

    it "round-trips xsd_validation" do
      config.xsd_validation = true
      expect(config.xsd_validation).to be(true)
    end

    it "round-trips log_save_fixes" do
      config.log_save_fixes = false
      expect(config.log_save_fixes).to be(false)
    end

    it "rejects a non-boolean value" do
      expect { config.validate_on_save = "yes" }
        .to raise_error(ArgumentError, /validate_on_save/)
    end
  end

  describe "#reset!" do
    before do
      config.validate_on_save = false
      config.xsd_validation = true
      config.log_save_fixes = false
    end

    it "restores default values after modification" do
      config.reset!
      expect(config).to have_attributes(
        validate_on_save: true, xsd_validation: false, log_save_fixes: true,
      )
    end
  end

  describe "namespace reconciliation" do
    it "still autoloads ConfigurationLoader" do
      expect(described_class::ConfigurationLoader).to be_a(Class)
    end
  end

  describe "Uniword.configuration" do
    it "returns a Configuration instance" do
      expect(Uniword.configuration).to be_a(described_class)
    end

    it "returns the same instance on repeated calls" do
      expect(Uniword.configuration).to equal(Uniword.configuration)
    end
  end

  describe "Uniword.configure" do
    it "yields the global configuration" do
      yielded = nil
      Uniword.configure { |c| yielded = c }
      expect(yielded).to equal(Uniword.configuration)
    end

    it "applies changes to the global configuration" do
      Uniword.configure { |c| c.xsd_validation = true }
      expect(Uniword.configuration.xsd_validation).to be(true)
    end
  end
end
