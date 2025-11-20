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

    it 'extracts variable expressions from markers' do
      # Create new template with mocked markers
      marker = Uniword::Template::TemplateMarker.new(
        type: :variable,
        expression: 'test_var',
        element: nil,
        position: 0
      )

      # Mock the extract_markers method
      allow_any_instance_of(Uniword::Template::TemplateParser).to receive(:parse).and_return([marker])
      fresh_template = described_class.new(document)

      expect(fresh_template.variables).to include('test_var')
    end
  end

  describe '#loops' do
    it 'returns array of loop information' do
      expect(template.loops).to be_an(Array)
    end

    it 'extracts loop collections from markers' do
      marker = Uniword::Template::TemplateMarker.new(
        type: :loop_start,
        collection: 'items',
        element: nil,
        position: 0
      )

      # Mock the parser
      allow_any_instance_of(Uniword::Template::TemplateParser).to receive(:parse).and_return([marker])
      fresh_template = described_class.new(document)

      loops = fresh_template.loops
      expect(loops.first[:collection]).to eq('items')
    end
  end

  describe '#conditionals' do
    it 'returns array of conditional markers' do
      expect(template.conditionals).to be_an(Array)
    end
  end

  describe '#template?' do
    context 'when template has markers' do
      it 'returns true' do
        marker = Uniword::Template::TemplateMarker.new(
          type: :variable,
          expression: 'test',
          element: nil,
          position: 0
        )

        # Mock the parser
        allow_any_instance_of(Uniword::Template::TemplateParser).to receive(:parse).and_return([marker])
        fresh_template = described_class.new(document)

        expect(fresh_template.template?).to be true
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

    it 'returns empty array for valid template' do
      allow(template).to receive(:markers).and_return([])
      expect(template.validate).to be_empty
    end
  end

  describe '#valid?' do
    it 'returns true when no validation errors' do
      allow(template).to receive(:validate).and_return([])
      expect(template).to be_valid
    end

    it 'returns false when validation errors exist' do
      allow(template).to receive(:validate).and_return(['Error 1'])
      expect(template).not_to be_valid
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