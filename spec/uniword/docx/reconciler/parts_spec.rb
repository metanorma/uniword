# frozen_string_literal: true

require "spec_helper"
require "uniword/docx"

RSpec.describe Uniword::Docx::Reconciler do
  describe "numbering reconciliation" do
    let(:profile) { Uniword::Docx::Profile.load(:word_2024_en) }
    let(:num_config_class) { Uniword::Wordprocessingml::NumberingConfiguration }

    def build_package_with_numbering
      package = Uniword::Docx::Package.new
      package.document = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new
      run.text = Uniword::Wordprocessingml::Text.new(value: "Item")
      para.runs << run
      package.document.body.paragraphs << para
      package
    end

    it "generates durableId for instances missing one" do
      package = build_package_with_numbering
      num_config = num_config_class.new
      num_config.add_instance(abstract_num_id: 0, num_id: 1)
      package.numbering = num_config

      described_class.new(package, profile: profile).reconcile

      inst = package.numbering.instances.first
      expect(inst.durable_id).not_to be_nil
      expect(inst.durable_id.to_s).to match(/^-?\d+$/)
    end

    it "does not overwrite existing durableId" do
      package = build_package_with_numbering
      num_config = num_config_class.new
      inst = num_config.add_instance(abstract_num_id: 0, num_id: 1)
      inst.durable_id = "42"
      package.numbering = num_config

      described_class.new(package, profile: profile).reconcile

      expect(package.numbering.instances.first.durable_id.to_s).to eq("42")
    end

    it "handles signed 32-bit overflow for durableId" do
      package = build_package_with_numbering
      num_config = num_config_class.new
      # Create several instances to trigger deterministic ID generation
      5.times do |i|
        num_config.add_instance(abstract_num_id: i, num_id: i + 1)
      end
      package.numbering = num_config

      described_class.new(package, profile: profile).reconcile

      package.numbering.instances.each do |inst|
        raw = inst.durable_id.to_i
        expect(raw).to be >= -2_147_483_648
        expect(raw).to be <= 2_147_483_647
      end
    end
  end
end
