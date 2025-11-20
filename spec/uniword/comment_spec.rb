# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Uniword::Comment do
  describe '#initialize' do
    it 'creates a comment with required attributes' do
      comment = described_class.new(
        author: 'John Doe',
        text: 'This needs revision'
      )

      expect(comment.author).to eq('John Doe')
      expect(comment.text).to eq('This needs revision')
      expect(comment.comment_id).not_to be_nil
    end

    it 'auto-generates comment_id if not provided' do
      comment = described_class.new(author: 'Jane')
      expect(comment.comment_id).not_to be_nil
      expect(comment.comment_id).not_to be_empty
    end

    it 'uses provided comment_id' do
      comment = described_class.new(
        author: 'Jane',
        comment_id: 'custom_123'
      )
      expect(comment.comment_id).to eq('custom_123')
    end

    it 'sets date to current time if not provided' do
      comment = described_class.new(author: 'Jane')
      expect(comment.date).not_to be_nil
    end

    it 'uses provided date' do
      date_str = '2024-01-15T10:30:00Z'
      comment = described_class.new(
        author: 'Jane',
        date: date_str
      )
      expect(comment.date).to eq(date_str)
    end

    it 'accepts initials' do
      comment = described_class.new(
        author: 'John Doe',
        initials: 'JD'
      )
      expect(comment.initials).to eq('JD')
    end
  end

  describe '#add_text' do
    it 'adds text as a paragraph' do
      comment = described_class.new(author: 'Editor')
      comment.add_text('First comment')

      expect(comment.paragraphs.count).to eq(1)
      expect(comment.paragraphs.first.text).to eq('First comment')
    end

    it 'supports multiple text additions' do
      comment = described_class.new(author: 'Editor')
      comment.add_text('First line')
      comment.add_text('Second line')

      expect(comment.paragraphs.count).to eq(2)
      expect(comment.text).to eq("First line\nSecond line")
    end

    it 'returns self for chaining' do
      comment = described_class.new(author: 'Editor')
      result = comment.add_text('Text')
      expect(result).to eq(comment)
    end
  end

  describe '#add_paragraph' do
    it 'adds a paragraph to comment' do
      comment = described_class.new(author: 'Editor')
      para = Uniword::Paragraph.new
      para.add_text('Comment paragraph')

      comment.add_paragraph(para)

      expect(comment.paragraphs.count).to eq(1)
      expect(comment.paragraphs.first).to eq(para)
    end

    it 'raises error if not a Paragraph' do
      comment = described_class.new(author: 'Editor')
      expect {
        comment.add_paragraph('not a paragraph')
      }.to raise_error(ArgumentError, /must be a Paragraph instance/)
    end

    it 'returns self for chaining' do
      comment = described_class.new(author: 'Editor')
      para = Uniword::Paragraph.new
      result = comment.add_paragraph(para)
      expect(result).to eq(comment)
    end
  end

  describe '#text' do
    it 'returns empty string for new comment' do
      comment = described_class.new(author: 'Editor')
      expect(comment.text).to eq('')
    end

    it 'returns text from single paragraph' do
      comment = described_class.new(author: 'Editor', text: 'Single line')
      expect(comment.text).to eq('Single line')
    end

    it 'joins multiple paragraphs with newlines' do
      comment = described_class.new(author: 'Editor')
      comment.add_text('First')
      comment.add_text('Second')
      expect(comment.text).to eq("First\nSecond")
    end
  end

  describe '#empty?' do
    it 'returns true for comment without paragraphs' do
      comment = described_class.new(author: 'Editor')
      expect(comment).to be_empty
    end

    it 'returns true for comment with empty paragraphs' do
      comment = described_class.new(author: 'Editor')
      comment.paragraphs << Uniword::Paragraph.new
      expect(comment).to be_empty
    end

    it 'returns false for comment with text' do
      comment = described_class.new(author: 'Editor', text: 'Content')
      expect(comment).not_to be_empty
    end
  end

  describe '#valid?' do
    it 'returns true for valid comment' do
      comment = described_class.new(
        author: 'John Doe',
        comment_id: '1'
      )
      expect(comment).to be_valid
    end

    it 'returns false without author' do
      comment = described_class.new(comment_id: '1')
      expect(comment).not_to be_valid
    end

    it 'returns false with empty author' do
      comment = described_class.new(author: '', comment_id: '1')
      expect(comment).not_to be_valid
    end

    it 'returns false without comment_id' do
      comment = described_class.new(author: 'John')
      comment.instance_variable_set(:@comment_id, nil)
      expect(comment).not_to be_valid
    end
  end

  describe '#accept' do
    it 'calls visitor visit_comment method' do
      comment = described_class.new(author: 'Editor')
      visitor = double('visitor')
      expect(visitor).to receive(:visit_comment).with(comment)
      comment.accept(visitor)
    end
  end

  describe 'XML serialization' do
    it 'serializes to XML with correct structure' do
      comment = described_class.new(
        comment_id: '1',
        author: 'John Doe',
        initials: 'JD',
        text: 'Review this'
      )

      xml = comment.to_xml
      expect(xml).to include('w:comment')
      expect(xml).to include('id="1"')
      expect(xml).to include('author="John Doe"')
      expect(xml).to include('initials="JD"')
    end
  end
end