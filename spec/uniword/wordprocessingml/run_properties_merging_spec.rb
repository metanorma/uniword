# frozen_string_literal: true

require "spec_helper"
require "uniword/wordprocessingml"

RSpec.describe Uniword::Wordprocessingml::RunProperties::Merging do
  let(:run_props_class) { Uniword::Wordprocessingml::RunProperties }

  describe "#merged_over" do
    it "returns a new RunProperties combining both" do
      base = run_props_class.new(bold: Uniword::Properties::Bold.new(val: true))
      override = run_props_class.new(italic: Uniword::Properties::Italic.new(val: true))

      result = override.merged_over(base)

      expect(result.bold).not_to be_nil
      expect(result.italic).not_to be_nil
    end

    it "uses base value when override has default" do
      base = run_props_class.new(bold: Uniword::Properties::Bold.new(val: true))
      override = run_props_class.new

      result = override.merged_over(base)

      expect(result.bold).not_to be_nil
    end

    it "uses override value when explicitly set" do
      base = run_props_class.new(bold: Uniword::Properties::Bold.new(val: true))
      override = run_props_class.new(bold: Uniword::Properties::Bold.new(val: false))

      result = override.merged_over(base)

      expect(result.bold).not_to be_nil
    end

    it "handles nil on both sides" do
      base = run_props_class.new
      override = run_props_class.new

      result = override.merged_over(base)

      expect(result.bold).to be_nil
      expect(result.italic).to be_nil
    end

    it "preserves complex attributes like fonts" do
      fonts = Uniword::Properties::RunFonts.new(ascii: "Arial")
      base = run_props_class.new(fonts: fonts)
      override = run_props_class.new

      result = override.merged_over(base)

      expect(result.fonts).not_to be_nil
      expect(result.fonts.ascii).to eq("Arial")
    end
  end
end
