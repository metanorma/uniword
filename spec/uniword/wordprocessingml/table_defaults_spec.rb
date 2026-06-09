# frozen_string_literal: true

require "spec_helper"
require "uniword/wordprocessingml"

RSpec.describe Uniword::Wordprocessingml::TableDefaults do
  describe ".default_table_look" do
    it "returns a TableLook with correct val" do
      look = described_class.default_table_look

      expect(look).to be_a(Uniword::Properties::TableLook)
      expect(look.val).to eq("04A0")
    end

    it "has first_row enabled and last_row disabled" do
      look = described_class.default_table_look

      expect(look.first_row).to eq(1)
      expect(look.last_row).to eq(0)
    end

    it "has first_column enabled and last_column disabled" do
      look = described_class.default_table_look

      expect(look.first_column).to eq(1)
      expect(look.last_column).to eq(0)
    end

    it "has no horizontal banding, vertical banding enabled" do
      look = described_class.default_table_look

      expect(look.no_h_band).to eq(0)
      expect(look.no_v_band).to eq(1)
    end

    it "returns a new instance each time" do
      look1 = described_class.default_table_look
      look2 = described_class.default_table_look

      expect(look1).not_to equal(look2)
    end
  end

  describe ".fill_missing_table_look" do
    it "fills nil val with default" do
      look = Uniword::Properties::TableLook.new
      described_class.fill_missing_table_look(look)

      expect(look.val).to eq("04A0")
    end

    it "preserves already-set values" do
      look = Uniword::Properties::TableLook.new(
        val: "00A0", first_row: 0
      )
      described_class.fill_missing_table_look(look)

      expect(look.val).to eq("00A0")
      expect(look.first_row).to eq(0)
      expect(look.last_row).to eq(0)
    end
  end

  describe "DEFAULT_TABLE_LOOK" do
    it "is frozen" do
      expect(described_class::DEFAULT_TABLE_LOOK).to be_frozen
    end
  end
end
