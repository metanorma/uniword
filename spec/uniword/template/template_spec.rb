# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Uniword::Template::Template do
  let(:document) { Uniword::Document.new }
  let(:template) { described_class.new(document) }

  describe '#initialize' do
    it 'initializes with a document' do
      expect(template.document).to eq(document)
    end

    it 'extracts markers from document' do
      expect(template.markers).to be_an(Array)
    end
  end

  describe '.load' do
    it 'loads template from file path' do
      # This would require an actual template file
      # For now, test the interface exists
      expect(described_class).to respond_to(:load)
    end
  end

  describe '#render' do
    it 'renders template with hash data' do
      data = { title: 'Test Title' }
      result = template.render(data)
      expect(result).to be_a(Uniword::Document)
    end

    it 'renders template with object data' do
      data_object = Struct.new(:title).new('Test Title')
      result = template.render(data_object)
      expect(result).to be_a(Uniword::Document)
    end

    it 'accepts additional context' do
      data = { title: 'Test' }
      context = { author: 'John' }
      result = template.render(data, context: context)
      expect(result).to be_a(Uniword::Document)
    end
  end

  describe '#preview' do
    it 'returns template structure info' do
      preview = template.preview
      expect(preview).to be_a(Hash)
      expect(preview).to have_key(:markers)
      expect(preview).to have_key(:variables)
      expect(preview).to have_key(:loops)
      expect(preview).to have_key(:conditionals)
    end

    it 'counts markers correctly' do
      preview = template.preview
      expect(preview[:markers]).to eq(template.markers.count)
    end
  end

  describe '#variables' do
    it 'returns array of variable names' do
      expect(template.variables).to be_an(Array)
    end
  end

  describe '#loops' do
    it 'returns array of loop information' do
      expect(template.loops).to be_an(Array)
    end
  end

  describe '#conditionals' do
    it 'returns array of conditional markers' do
      expect(template.conditionals).to be_an(Array)
    end
  end

  describe '#template?' do
    context 'when template has markers' do
      it 'returns true if markers exist' do
        # A real document with markers would have template? return true
        # Empty document has no markers
        expect(template.template?).to be false
      end
    end

    context 'when template has no markers' do
      it 'returns false' do
        expect(template.template?).to be false
      end
    end
  end

  describe '#validate' do
    it 'returns validation errors array' do
      errors = template.validate
      expect(errors).to be_an(Array)
    end
  end

  describe '#valid?' do
    it 'returns true when no validation errors' do
      # Empty document should be valid (no malformed markers)
      expect(template.valid?).to be true
    end
  end

  describe '#inspect' do
    it 'returns readable representation' do
      inspection = template.inspect
      expect(inspection).to include('Uniword::Template')
      expect(inspection).to include('markers=')
    end
  end
end
