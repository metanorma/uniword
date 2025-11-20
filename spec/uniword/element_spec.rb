# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Uniword::Element do
  # Create a concrete test subclass for testing
  let(:test_element_class) do
    Class.new(described_class) do
      def accept(visitor)
        visitor.visit_test_element(self)
      end
    end
  end

  # Create another test subclass for inheritance testing
  let(:another_element_class) do
    Class.new(described_class) do
      def accept(visitor)
        visitor.visit_another_element(self)
      end
    end
  end

  describe '.inherited' do
    it 'is called when a subclass is created' do
      expect { test_element_class }.not_to raise_error
    end

    it 'allows multiple subclasses to be created' do
      expect { test_element_class }.not_to raise_error
      expect { another_element_class }.not_to raise_error
    end
  end

  describe '.abstract?' do
    it 'returns true for the base Element class' do
      expect(described_class.abstract?).to be true
    end

    it 'returns false for concrete subclasses' do
      expect(test_element_class.abstract?).to be false
    end
  end

  describe '#id' do
    it 'allows setting an id attribute' do
      element = test_element_class.new(id: 'element-123')
      expect(element.id).to eq('element-123')
    end

    it 'allows id to be nil' do
      element = test_element_class.new
      expect(element.id).to be_nil
    end

    it 'allows updating the id' do
      element = test_element_class.new(id: 'old-id')
      element.id = 'new-id'
      expect(element.id).to eq('new-id')
    end
  end

  describe '#accept' do
    context 'when implemented by subclass' do
      it 'accepts a visitor object' do
        element = test_element_class.new
        visitor = double('visitor')

        expect(visitor).to receive(:visit_test_element).with(element)
        element.accept(visitor)
      end
    end

    context 'when not implemented by subclass' do
      let(:incomplete_class) do
        Class.new(described_class) # Does not override accept
      end

      it 'raises NotImplementedError' do
        element = incomplete_class.new
        visitor = double('visitor')

        expect { element.accept(visitor) }
          .to raise_error(NotImplementedError, /must implement accept/)
      end

      it 'includes class name in error message' do
        element = incomplete_class.new
        visitor = double('visitor')

        expect { element.accept(visitor) }
          .to raise_error(NotImplementedError, /#{incomplete_class}/)
      end
    end
  end

  describe '#valid?' do
    it 'returns true by default' do
      element = test_element_class.new
      expect(element.valid?).to be true
    end

    it 'can be called multiple times' do
      element = test_element_class.new
      expect(element.valid?).to be true
      expect(element.valid?).to be true
    end

    context 'with custom validation in subclass' do
      let(:validated_class) do
        Class.new(described_class) do
          attribute :required_field, :string

          def accept(visitor)
            visitor.visit_validated_element(self)
          end

          protected

          def required_attributes_valid?
            !required_field.nil? && !required_field.empty?
          end
        end
      end

      it 'returns false when validation fails' do
        element = validated_class.new
        expect(element.valid?).to be false
      end

      it 'returns true when validation passes' do
        element = validated_class.new(required_field: 'value')
        expect(element.valid?).to be true
      end
    end
  end

  describe 'inheritance from Lutaml::Model::Serializable' do
    it 'inherits from Lutaml::Model::Serializable' do
      expect(described_class.ancestors).to include(Lutaml::Model::Serializable)
    end

    it 'supports lutaml-model attributes' do
      element = test_element_class.new(id: 'test-123')
      expect(element).to respond_to(:id)
      expect(element).to respond_to(:id=)
    end
  end

  describe 'object creation' do
    it 'creates instances with default values' do
      element = test_element_class.new
      expect(element).to be_a(Uniword::Element)
      expect(element.id).to be_nil
    end

    it 'creates instances with provided attributes' do
      element = test_element_class.new(id: 'custom-id')
      expect(element.id).to eq('custom-id')
    end
  end
end
