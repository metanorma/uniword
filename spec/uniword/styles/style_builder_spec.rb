# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Uniword::Styles::StyleBuilder do
  let(:document) { Uniword::Document.new }
  let(:builder) { described_class.new(document, style_library: 'minimal') }

  describe '#initialize' do
    it 'initializes with document and style library' do
      expect(builder.document).to eq(document)
      expect(builder.library).to be_a(Uniword::Styles::StyleLibrary)
    end
  end

  describe '#build' do
    it 'executes DSL block and returns document' do
      result = builder.build do
        paragraph :title, 'Test Title'
      end

      expect(result).to eq(document)
      expect(document.paragraphs.size).to eq(1)
    end
  end

  describe '#paragraph' do
    it 'creates paragraph with style' do
      para = builder.paragraph(:title, 'Document Title')

      expect(para).to be_a(Uniword::Wordprocessingml::Paragraph)
      expect(para.text).to eq('Document Title')
      # v2.0 API: Check paragraph is in document body paragraphs
      expect(document.body.paragraphs).to include(para)
    end

    it 'applies paragraph properties from style' do
      para = builder.paragraph(:title, 'Centered Title')

      expect(para.properties).not_to be_nil
      # v2.0 API: alignment is a wrapper object, check its value
      expect(para.properties.alignment).to eq('center')
    end

    it 'applies run properties from style' do
      para = builder.paragraph(:title, 'Bold Title')

      # Check that default run properties are stored
      default_props = para.instance_variable_get(:@default_run_properties)
      expect(default_props).not_to be_nil
      expect(default_props[:bold]).to be true
    end

    it 'creates paragraph with block' do
      para = builder.paragraph(:normal) do |p|
        p.text 'Hello '
        p.text 'World', :bold
      end

      expect(para.text).to include('Hello')
    end
  end

  describe '#list' do
    it 'creates list with items' do
      builder.list(:bullet_list) do
        item 'First point'
        item 'Second point'
      end

      expect(document.paragraphs.size).to eq(2)
      # v2.0 API: paragraphs returns Paragraph objects, check text content
      first_para = document.paragraphs.first
      expect(first_para).to be_a(Uniword::Wordprocessingml::Paragraph)
      expect(first_para.text).to eq('First point')
    end

    it 'applies numbering to list items' do
      builder.list(:bullet_list) do
        item 'First'
      end

      para = document.paragraphs.first
      # v2.0 API: Use properties.num_id instead of numbered? method
      expect(para.properties).not_to be_nil
      expect(para.properties.num_id).not_to be_nil
    end

    it 'supports nested list items' do
      builder.list(:bullet_list) do
        item 'Level 0'
        item 'Level 1', level: 1
      end

      expect(document.paragraphs.size).to eq(2)
    end
  end

  describe '#table' do
    it 'creates table' do
      tbl = builder.table do
        row do
          cell 'Cell 1'
          cell 'Cell 2'
        end
      end

      expect(tbl).to be_a(Uniword::Wordprocessingml::Table)
      expect(document.tables).to include(tbl)
    end

    it 'creates table with header row' do
      builder.table do
        row header: true do
          cell 'Header 1'
          cell 'Header 2'
        end
      end

      table = document.tables.first
      # v2.0 API: Check properties.header instead of header? method
      first_row = table.rows.first
      expect(first_row.properties).not_to be_nil
      expect(first_row.properties.header).to be true
    end

    # PENDING: Implementation bug - DSL::TableContext uses cell.colspan= which
    # doesn't exist on TableCell. Should use cell.properties.grid_span=
    it 'supports cell spanning' do
      pending 'Implementation needs to use cell.properties.grid_span='
      builder.table do
        row do
          cell 'Merged', colspan: 2
        end
      end

      table = document.tables.first
      cell = table.rows.first.cells.first
      # v2.0 API: Check properties.grid_span instead of colspan
      expect(cell.properties.grid_span).to eq(2)
    end
  end

  describe 'integration with ISO standard library' do
    let(:builder) { described_class.new(document, style_library: 'iso_standard') }

    it 'builds complete document' do
      builder.build do
        paragraph :title, 'ISO 8601-2:2026'
        paragraph :subtitle, 'Date and time'

        paragraph :heading_1, '1. Scope'
        paragraph :body_text, 'This document specifies...'

        list :bullet_list do
          item 'First point'
          item 'Second point'
        end

        table do
          row header: true do
            cell 'Column 1'
            cell 'Column 2'
          end
          row do
            cell 'Data 1'
            cell 'Data 2'
          end
        end
      end

      expect(document.paragraphs.size).to eq(6) # 4 paragraphs + 2 list items
      expect(document.tables.size).to eq(1)
    end
  end

  describe 'style inheritance' do
    let(:builder) { described_class.new(document, style_library: 'iso_standard') }

    it 'inherits properties from base style' do
      # heading_2 inherits from heading_1
      para = builder.paragraph(:heading_2, 'Subheading')

      # Should inherit font from heading_1
      default_props = para.instance_variable_get(:@default_run_properties)
      expect(default_props[:font]).to eq('Arial')
    end
  end
end
