# frozen_string_literal: true

require 'spec_helper'
require 'uniword/builder'

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

  describe 'adding text via Builder' do
    it 'adds text as a paragraph' do
      comment = described_class.new(author: 'Editor')
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'First comment')
      para.runs << run
      comment.paragraphs << para

      expect(comment.paragraphs.count).to eq(1)
      expect(comment.paragraphs.first.text).to eq('First comment')
    end

    it 'supports multiple text additions' do
      comment = described_class.new(author: 'Editor')
      para1 = Uniword::Wordprocessingml::Paragraph.new
      run1 = Uniword::Wordprocessingml::Run.new(text: 'First line')
      para1.runs << run1
      comment.paragraphs << para1
      para2 = Uniword::Wordprocessingml::Paragraph.new
      run2 = Uniword::Wordprocessingml::Run.new(text: 'Second line')
      para2.runs << run2
      comment.paragraphs << para2

      expect(comment.paragraphs.count).to eq(2)
      expect(comment.text).to eq("First line\nSecond line")
    end

    it 'returns self for chaining via CommentBuilder' do
      comment = described_class.new(author: 'Editor')
      builder = Uniword::Builder::CommentBuilder.from_model(comment)
      result = builder << 'Text'
      expect(result).to eq(builder)
    end
  end

  describe '#paragraphs' do
    it 'adds a paragraph to comment' do
      comment = described_class.new(author: 'Editor')
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'Comment paragraph')
      para.runs << run

      comment.paragraphs << para

      expect(comment.paragraphs.count).to eq(1)
      expect(comment.paragraphs.first).to eq(para)
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
      para1 = Uniword::Wordprocessingml::Paragraph.new
      run1 = Uniword::Wordprocessingml::Run.new(text: 'First')
      para1.runs << run1
      comment.paragraphs << para1
      para2 = Uniword::Wordprocessingml::Paragraph.new
      run2 = Uniword::Wordprocessingml::Run.new(text: 'Second')
      para2.runs << run2
      comment.paragraphs << para2
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
      comment.paragraphs << Uniword::Wordprocessingml::Paragraph.new
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
      # Accept both prefixed (w:comment) and unprefixed with namespace declaration
      expect(xml).to match(/(<w:comment|<comment[^>]*xmlns=)/)
      # Accept both prefixed and unprefixed attributes
      expect(xml).to match(/(w:id=|id="1")/)
      expect(xml).to match(/(w:author=|author="John Doe")/)
      expect(xml).to match(/(w:initials=|initials="JD")/)
    end
  end
end
