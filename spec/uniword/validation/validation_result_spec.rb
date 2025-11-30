# frozen_string_literal: true

require 'spec_helper'
require 'uniword/validation/validation_result'

RSpec.describe Uniword::Validation::ValidationResult do
  let(:mock_link) do
    double('Link', url: 'https://example.com', anchor: nil)
  end

  describe '.success' do
    it 'creates a success result' do
      result = described_class.success(mock_link)

      expect(result.status).to eq(:success)
      expect(result.valid?).to be true
      expect(result.failure?).to be false
      expect(result.message).to be_nil
    end

    it 'accepts metadata' do
      result = described_class.success(mock_link, metadata: { code: 200 })

      expect(result.metadata[:code]).to eq(200)
    end
  end

  describe '.failure' do
    it 'creates a failure result' do
      result = described_class.failure(mock_link, '404 Not Found')

      expect(result.status).to eq(:failure)
      expect(result.valid?).to be false
      expect(result.failure?).to be true
      expect(result.message).to eq('404 Not Found')
    end

    it 'accepts metadata' do
      result = described_class.failure(
        mock_link,
        'Not found',
        metadata: { status_code: 404 }
      )

      expect(result.metadata[:status_code]).to eq(404)
    end
  end

  describe '.warning' do
    it 'creates a warning result' do
      result = described_class.warning(mock_link, 'Redirect detected')

      expect(result.status).to eq(:warning)
      expect(result.warning?).to be true
      expect(result.message).to eq('Redirect detected')
    end
  end

  describe '.unknown' do
    it 'creates an unknown result' do
      result = described_class.unknown(mock_link)

      expect(result.status).to eq(:unknown)
      expect(result.unknown?).to be true
      expect(result.message).to eq('No checker available')
    end

    it 'accepts custom message' do
      result = described_class.unknown(mock_link, 'Custom message')

      expect(result.message).to eq('Custom message')
    end
  end

  describe '#link_identifier' do
    it 'returns URL for links with URL' do
      result = described_class.success(mock_link)

      expect(result.link_identifier).to eq('https://example.com')
    end

    it 'returns anchor for links with anchor' do
      anchor_link = double('Link', url: nil, anchor: 'section1')
      result = described_class.success(anchor_link)

      expect(result.link_identifier).to eq('#section1')
    end

    it 'returns ID for links with ID' do
      id_link = double('Link', id: 42)
      result = described_class.success(id_link)

      expect(result.link_identifier).to eq('42')
    end

    it 'returns name for links with name' do
      name_link = double('Link', name: 'bookmark1')
      result = described_class.success(name_link)

      expect(result.link_identifier).to eq('bookmark1')
    end

    it 'returns string representation as fallback' do
      simple_link = 'http://example.com'
      result = described_class.success(simple_link)

      expect(result.link_identifier).to eq('http://example.com')
    end
  end

  describe '#error_message' do
    it 'returns the message' do
      result = described_class.failure(mock_link, 'Error occurred')

      expect(result.error_message).to eq('Error occurred')
    end
  end

  describe '#to_h' do
    it 'converts to hash' do
      result = described_class.failure(
        mock_link,
        'Not found',
        metadata: { code: 404 }
      )

      hash = result.to_h

      expect(hash[:status]).to eq(:failure)
      expect(hash[:link]).to eq('https://example.com')
      expect(hash[:message]).to eq('Not found')
      expect(hash[:metadata]).to eq({ code: 404 })
    end

    it 'omits nil values' do
      result = described_class.success(mock_link)

      hash = result.to_h

      expect(hash).not_to have_key(:message)
    end
  end

  describe '#to_s' do
    it 'formats success result' do
      result = described_class.success(mock_link)

      expect(result.to_s).to eq('[SUCCESS] https://example.com')
    end

    it 'formats failure result with message' do
      result = described_class.failure(mock_link, '404 Not Found')

      expect(result.to_s).to eq('[FAILURE] https://example.com: 404 Not Found')
    end
  end

  describe '#inspect' do
    it 'provides detailed representation' do
      result = described_class.failure(mock_link, 'Error')

      expect(result.inspect).to include('ValidationResult')
      expect(result.inspect).to include('status=failure')
      expect(result.inspect).to include('https://example.com')
      expect(result.inspect).to include('Error')
    end
  end
end
