# frozen_string_literal: true

# Shared examples for Uniword tests

RSpec.shared_examples 'a serializable element' do
  it 'responds to valid?' do
    expect(subject).to respond_to(:valid?)
  end

  it 'responds to accept' do
    expect(subject).to respond_to(:accept)
  end
end
