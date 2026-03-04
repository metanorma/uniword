# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Uniword::Image do
  describe '#initialize' do
    it 'creates an image with relationship_id' do
      image = described_class.new(relationship_id: 'rId1')
      expect(image.relationship_id).to eq('rId1')
    end

    it 'creates an image with dimensions' do
      image = described_class.new(
        relationship_id: 'rId1',
        width: 1_270_000,
        height: 952_500
      )
      expect(image.width).to eq(1_270_000)
      expect(image.height).to eq(952_500)
    end

    it 'creates an image with alt text' do
      image = described_class.new(
        relationship_id: 'rId1',
        alt_text: 'A beautiful landscape'
      )
      expect(image.alt_text).to eq('A beautiful landscape')
    end

    it 'creates an image with title' do
      image = described_class.new(
        relationship_id: 'rId1',
        title: 'Landscape Photo'
      )
      expect(image.title).to eq('Landscape Photo')
    end

    it 'creates an image with filename' do
      image = described_class.new(
        relationship_id: 'rId1',
        filename: 'image.jpg'
      )
      expect(image.filename).to eq('image.jpg')
    end
  end

  describe '#accept' do
    it 'accepts a visitor' do
      image = described_class.new(relationship_id: 'rId1')
      visitor = double('visitor')

      expect(visitor).to receive(:visit_image).with(image)
      image.accept(visitor)
    end
  end

  describe '#width_in_points' do
    it 'returns nil when width is not set' do
      image = described_class.new(relationship_id: 'rId1')
      expect(image.width_in_points).to be_nil
    end

    it 'converts EMUs to points' do
      image = described_class.new(relationship_id: 'rId1', width: 1_270_000)
      expect(image.width_in_points).to be_within(0.01).of(100.0)
    end
  end

  describe '#height_in_points' do
    it 'returns nil when height is not set' do
      image = described_class.new(relationship_id: 'rId1')
      expect(image.height_in_points).to be_nil
    end

    it 'converts EMUs to points' do
      image = described_class.new(relationship_id: 'rId1', height: 952_500)
      expect(image.height_in_points).to be_within(0.01).of(75.0)
    end
  end

  describe '#width_in_pixels' do
    it 'returns nil when width is not set' do
      image = described_class.new(relationship_id: 'rId1')
      expect(image.width_in_pixels).to be_nil
    end

    it 'converts EMUs to pixels (96 DPI)' do
      image = described_class.new(relationship_id: 'rId1', width: 1_270_000)
      expect(image.width_in_pixels).to eq(133)
    end
  end

  describe '#height_in_pixels' do
    it 'returns nil when height is not set' do
      image = described_class.new(relationship_id: 'rId1')
      expect(image.height_in_pixels).to be_nil
    end

    it 'converts EMUs to pixels (96 DPI)' do
      image = described_class.new(relationship_id: 'rId1', height: 952_500)
      expect(image.height_in_pixels).to eq(100)
    end
  end

  describe '#aspect_ratio' do
    it 'returns nil when dimensions are not set' do
      image = described_class.new(relationship_id: 'rId1')
      expect(image.aspect_ratio).to be_nil
    end

    it 'returns nil when only width is set' do
      image = described_class.new(relationship_id: 'rId1', width: 1_270_000)
      expect(image.aspect_ratio).to be_nil
    end

    it 'returns nil when only height is set' do
      image = described_class.new(relationship_id: 'rId1', height: 952_500)
      expect(image.aspect_ratio).to be_nil
    end

    it 'calculates aspect ratio' do
      image = described_class.new(
        relationship_id: 'rId1',
        width: 1_600_000,
        height: 1_200_000
      )
      expect(image.aspect_ratio).to be_within(0.01).of(1.33)
    end

    it 'handles square images' do
      image = described_class.new(
        relationship_id: 'rId1',
        width: 1_000_000,
        height: 1_000_000
      )
      expect(image.aspect_ratio).to eq(1.0)
    end
  end

  describe '#valid?' do
    # v2.0 API: Image inherits from Element which has a valid? method
    # that returns true by default
    it 'returns true when relationship_id is present' do
      image = described_class.new(relationship_id: 'rId1')
      expect(image.valid?).to be true
    end

    it 'returns true when relationship_id is nil (base class default)' do
      # Note: The base Element class returns true by default
      image = described_class.new
      expect(image.valid?).to be true
    end

    it 'returns true when relationship_id is empty (base class default)' do
      image = described_class.new(relationship_id: '')
      expect(image.valid?).to be true
    end
  end

  describe 'inheritance' do
    it 'inherits from Element (which inherits from Lutaml::Model::Serializable)' do
      expect(described_class.ancestors).to include(Uniword::Element)
      expect(described_class.ancestors).to include(Lutaml::Model::Serializable)
    end
  end
end
