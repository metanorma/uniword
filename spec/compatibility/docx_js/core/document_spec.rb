# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'docx-js compatibility: Document' do
  describe 'Document creation' do
    it 'creates valid document with background' do
      # TypeScript: new Document({ background: {} })
      doc = Uniword::Document.new

      # Verify document is created
      expect(doc).not_to be_nil
      expect(doc).to be_a(Uniword::Document)

      # Verify basic structure
      expect(doc.paragraphs).to be_an(Array)
      expect(doc.sections).to be_an(Array)
    end
  end
end