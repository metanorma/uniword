# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Uniword::Document do
  describe '.new' do
    it 'creates a new document' do
      document = described_class.new
      expect(document).to be_a(Uniword::Document)
    end

    it 'initializes with empty elements array' do
      document = described_class.new
      expect(document.elements).to eq([])
    end
  end

  describe '#add_element' do
    let(:document) { described_class.new }
    let(:element) { Uniword::Paragraph.new }

    it 'adds an element to the document' do
      document.add_element(element)
      expect(document.elements).to include(element)
    end

    it 'raises error for non-element objects' do
      expect { document.add_element('not an element') }.to raise_error(ArgumentError)
    end
  end
end
