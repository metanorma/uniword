# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Ooxml::Types::ThemeColorValue do
  let(:st_theme_color) do
    %w[dark1 light1 dark2 light2 accent1 accent2 accent3 accent4 accent5
       accent6 hyperlink followedHyperlink none background1 text1
       background2 text2]
  end

  describe "VALUES" do
    it "matches the full ST_ThemeColor enumeration from ECMA-376" do
      expect(described_class::VALUES).to eq(st_theme_color)
    end
  end
end
