# frozen_string_literal: true

require "spec_helper"
require "uniword/protect"

RSpec.describe Uniword::Protect::Manager do
  let(:doc) { Uniword::Wordprocessingml::DocumentRoot.new }
  let(:manager) { described_class.new(doc) }

  describe "#apply" do
    it "applies read-only protection" do
      manager.apply(:read_only)
      expect(manager.protected?).to be(true)
    end

    it "applies protection with password" do
      manager.apply(:comments, password: "secret")
      expect(manager.protected?).to be(true)
      expect(manager.info[:password_protected]).to be(true)
    end

    it "raises for invalid protection type" do
      expect do
        manager.apply(:invalid)
      end.to raise_error(ArgumentError, /Invalid protection type/)
    end

    it "applies tracked_changes protection" do
      manager.apply(:tracked_changes)
      expect(manager.protected?).to be(true)
    end

    it "applies forms protection" do
      manager.apply(:forms)
      expect(manager.protected?).to be(true)
    end
  end

  describe "#remove" do
    it "removes protection" do
      manager.apply(:read_only)
      manager.remove
      expect(manager.protected?).to be(false)
    end
  end

  describe "#info" do
    it "returns nil when not protected" do
      expect(manager.info).to be_nil
    end

    it "returns protection details" do
      manager.apply(:read_only)
      info = manager.info
      expect(info).to include(:type, :password_protected)
    end
  end
end
