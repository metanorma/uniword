# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Uniword::Accessibility::Rules::ImageAltTextRule do
  let(:config) do
    {
      wcag_criterion: '1.1.1 Non-text Content',
      level: 'A',
      enabled: true,
      severity: :error,
      check_quality: true,
      min_length: 10,
      max_length: 150,
      suggestion: 'Add descriptive alternative text'
    }
  end

  subject(:rule) { described_class.new(config) }

  describe '#check' do
    let(:document) { double('Document') }

    context 'with no images' do
      before do
        allow(document).to receive(:images).and_return([])
      end

      it 'returns no violations' do
        expect(rule.check(document)).to be_empty
      end
    end

    context 'with image missing alt text' do
      let(:image_no_alt) { double('Image', alt_text: nil) }

      before do
        allow(document).to receive(:images).and_return([image_no_alt])
      end

      it 'returns violation' do
        violations = rule.check(document)
        expect(violations.count).to eq(1)
      end

      it 'creates error violation' do
        violation = rule.check(document).first
        expect(violation.severity).to eq(:error)
      end

      it 'includes helpful message' do
        violation = rule.check(document).first
        expect(violation.message).to include('Image 1 missing alternative text')
      end

      it 'includes suggestion' do
        violation = rule.check(document).first
        expect(violation.suggestion).to include('descriptive alternative text')
      end
    end

    context 'with image having empty alt text' do
      let(:image_empty_alt) { double('Image', alt_text: '   ') }

      before do
        allow(document).to receive(:images).and_return([image_empty_alt])
      end

      it 'returns violation' do
        violations = rule.check(document)
        expect(violations.count).to eq(1)
      end
    end

    context 'with valid alt text' do
      let(:image_with_alt) { double('Image', alt_text: 'A beautiful sunset over mountains') }

      before do
        allow(document).to receive(:images).and_return([image_with_alt])
      end

      it 'returns no violations' do
        expect(rule.check(document)).to be_empty
      end
    end

    context 'when check_quality is enabled' do
      context 'with alt text too short' do
        let(:image_short_alt) { double('Image', alt_text: 'Logo') }

        before do
          allow(document).to receive(:images).and_return([image_short_alt])
        end

        it 'returns warning violation' do
          violations = rule.check(document)
          expect(violations.count).to eq(1)
          expect(violations.first.severity).to eq(:warning)
        end

        it 'mentions length in message' do
          violation = rule.check(document).first
          expect(violation.message).to include('too short')
          expect(violation.message).to include('4 chars')
        end
      end

      context 'with alt text too long' do
        let(:long_text) { 'a' * 200 }
        let(:image_long_alt) { double('Image', alt_text: long_text) }

        before do
          allow(document).to receive(:images).and_return([image_long_alt])
        end

        it 'returns warning violation' do
          violations = rule.check(document)
          expect(violations.count).to eq(1)
          expect(violations.first.severity).to eq(:warning)
        end

        it 'mentions length in message' do
          violation = rule.check(document).first
          expect(violation.message).to include('too long')
        end
      end

      context 'with generic alt text' do
        [
          'image',
          'picture',
          'photo',
          'IMAGE',
          'image of sunset',
          'picture of'
        ].each do |generic_text|
          context "with '#{generic_text}'" do
            let(:image_generic) { double('Image', alt_text: generic_text) }

            before do
              allow(document).to receive(:images).and_return([image_generic])
            end

            it 'returns warning for generic text' do
              violations = rule.check(document)
              expect(violations.any? { |v| v.message.include?('generic') }).to be true
            end
          end
        end
      end

      context 'with good alt text' do
        let(:image_good) { double('Image', alt_text: 'Company logo showing blue mountain') }

        before do
          allow(document).to receive(:images).and_return([image_good])
        end

        it 'returns no violations' do
          expect(rule.check(document)).to be_empty
        end
      end
    end

    context 'when check_quality is disabled' do
      let(:config_no_quality) do
        {
          wcag_criterion: '1.1.1 Non-text Content',
          level: 'A',
          enabled: true,
          severity: :error,
          check_quality: false,
          min_length: 10,
          max_length: 150,
          suggestion: 'Add descriptive alternative text'
        }
      end
      let(:rule_no_quality) { described_class.new(config_no_quality) }
      let(:image_short) { double('Image', alt_text: 'Logo') }

      before do
        allow(document).to receive(:images).and_return([image_short])
      end

      it 'does not check quality' do
        violations = rule_no_quality.check(document)
        expect(violations).to be_empty
      end
    end

    context 'with multiple images' do
      let(:image1) { double('Image', alt_text: nil) }
      let(:image2) { double('Image', alt_text: 'Valid description here') }
      let(:image3) { double('Image', alt_text: 'img') }

      before do
        allow(document).to receive(:images).and_return([image1, image2, image3])
      end

      it 'checks all images' do
        violations = rule.check(document)
        expect(violations.count).to be >= 1
      end

      it 'reports correct image numbers' do
        violations = rule.check(document)
        messages = violations.map(&:message).join(' ')
        expect(messages).to include('Image 1')
        expect(messages).to include('Image 3')
      end
    end
  end

  describe '#enabled?' do
    it 'returns true when enabled' do
      expect(rule.enabled?).to be true
    end

    context 'when disabled in config' do
      let(:config) { super().merge(enabled: false) }

      it 'returns false' do
        expect(rule.enabled?).to be false
      end
    end
  end
end
