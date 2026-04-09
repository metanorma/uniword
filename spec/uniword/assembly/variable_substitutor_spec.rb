# frozen_string_literal: true

require 'spec_helper'
require 'uniword/assembly/variable_substitutor'

RSpec.describe Uniword::Assembly::VariableSubstitutor do
  describe '#initialize' do
    it 'creates substitutor with variables' do
      sub = described_class.new({ title: 'Test' })
      expect(sub.variables['title']).to eq('Test')
    end

    it 'normalizes variable keys to strings' do
      sub = described_class.new({ title: 'Test', version: '1.0' })
      expect(sub.variables.keys).to all(be_a(String))
    end

    it 'handles nested variables' do
      sub = described_class.new({
                                  doc: { title: 'Test', version: '1.0' }
                                })
      expect(sub.variables['doc']['title']).to eq('Test')
    end
  end

  describe '#substitute' do
    let(:sub) do
      described_class.new({
                            title: 'ISO 8601',
                            version: '2.0',
                            date: '2026-01-15'
                          })
    end

    it 'substitutes single variable' do
      result = sub.substitute('Title: {title}')
      expect(result).to eq('Title: ISO 8601')
    end

    it 'substitutes multiple variables' do
      result = sub.substitute('Title: {title}, Version: {version}')
      expect(result).to eq('Title: ISO 8601, Version: 2.0')
    end

    it 'leaves unknown variables as placeholders' do
      result = sub.substitute('Title: {title}, Author: {author}')
      expect(result).to eq('Title: ISO 8601, Author: {author}')
    end

    it 'handles text without variables' do
      result = sub.substitute('No variables here')
      expect(result).to eq('No variables here')
    end

    it 'handles empty string' do
      result = sub.substitute('')
      expect(result).to eq('')
    end

    it 'handles nil input' do
      result = sub.substitute(nil)
      expect(result).to be_nil
    end

    it 'substitutes nested variables' do
      sub = described_class.new({
                                  doc: { title: 'Test Doc' }
                                })
      result = sub.substitute('Title: {doc.title}')
      expect(result).to eq('Title: Test Doc')
    end

    it 'handles multiple nested levels' do
      sub = described_class.new({
                                  org: {
                                    info: {
                                      name: 'ISO'
                                    }
                                  }
                                })
      result = sub.substitute('Organization: {org.info.name}')
      expect(result).to eq('Organization: ISO')
    end
  end

  describe '#substitute_document' do
    let(:sub) do
      described_class.new({
                            title: 'Test Document',
                            version: '1.0'
                          })
    end

    let(:document) do
      doc = Uniword::Wordprocessingml::DocumentRoot.new

      para1 = Uniword::Wordprocessingml::Paragraph.new
      run1 = Uniword::Wordprocessingml::Run.new
      run1.text = 'Title: {title}'
      para1.runs << run1
      doc.body.paragraphs << para1

      para2 = Uniword::Wordprocessingml::Paragraph.new
      run2 = Uniword::Wordprocessingml::Run.new
      run2.text = 'Version: {version}'
      para2.runs << run2
      doc.body.paragraphs << para2

      doc
    end

    it 'substitutes variables in document paragraphs' do
      sub.substitute_document(document)

      expect(document.body.paragraphs[0].runs[0].text).to eq('Title: Test Document')
      expect(document.body.paragraphs[1].runs[0].text).to eq('Version: 1.0')
    end

    it 'returns the document' do
      result = sub.substitute_document(document)
      expect(result).to be(document)
    end

    it 'handles document without variables' do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new
      run.text = 'No variables'
      para.runs << run
      doc.body.paragraphs << para

      sub.substitute_document(doc)
      expect(doc.body.paragraphs[0].runs[0].text).to eq('No variables')
    end
  end

  describe '#set_variable' do
    let(:sub) { described_class.new({ title: 'Original' }) }

    it 'adds new variable' do
      sub.set_variable(:author, 'John Doe')
      expect(sub.get_variable('author')).to eq('John Doe')
    end

    it 'updates existing variable' do
      sub.set_variable(:title, 'Updated')
      expect(sub.get_variable('title')).to eq('Updated')
    end

    it 'normalizes key to string' do
      sub.set_variable(:new_var, 'value')
      expect(sub.variables).to have_key('new_var')
    end
  end

  describe '#get_variable' do
    let(:sub) do
      described_class.new({
                            title: 'Test',
                            doc: { version: '1.0' }
                          })
    end

    it 'gets simple variable' do
      expect(sub.get_variable('title')).to eq('Test')
    end

    it 'gets nested variable' do
      expect(sub.get_variable('doc.version')).to eq('1.0')
    end

    it 'returns nil for non-existent variable' do
      expect(sub.get_variable('nonexistent')).to be_nil
    end

    it 'works with symbol keys' do
      expect(sub.get_variable(:title)).to eq('Test')
    end
  end

  describe '#variable?' do
    let(:sub) do
      described_class.new({
                            title: 'Test',
                            doc: { version: '1.0' }
                          })
    end

    it 'returns true for existing variable' do
      expect(sub.variable?('title')).to be true
    end

    it 'returns true for nested variable' do
      expect(sub.variable?('doc.version')).to be true
    end

    it 'returns false for non-existent variable' do
      expect(sub.variable?('nonexistent')).to be false
    end

    it 'works with symbol keys' do
      expect(sub.variable?(:title)).to be true
    end
  end

  describe '#variable_names' do
    let(:sub) do
      described_class.new({
                            title: 'Test',
                            version: '1.0',
                            doc: {
                              number: 'ISO 8601',
                              year: '2026'
                            }
                          })
    end

    it 'returns all variable names including nested' do
      names = sub.variable_names
      expect(names).to include('title', 'version', 'doc', 'doc.number', 'doc.year')
    end

    it 'returns array of strings' do
      names = sub.variable_names
      expect(names).to all(be_a(String))
    end
  end

  describe 'type conversion' do
    it 'converts integer to string' do
      sub = described_class.new({ count: 42 })
      result = sub.substitute('Count: {count}')
      expect(result).to eq('Count: 42')
    end

    it 'converts boolean to string' do
      sub = described_class.new({ flag: true })
      result = sub.substitute('Flag: {flag}')
      expect(result).to eq('Flag: true')
    end

    it 'converts float to string' do
      sub = described_class.new({ price: 19.99 })
      result = sub.substitute('Price: {price}')
      expect(result).to eq('Price: 19.99')
    end
  end
end
