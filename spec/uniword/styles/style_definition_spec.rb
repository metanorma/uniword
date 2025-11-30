# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Uniword::Styles::StyleDefinition do
  describe 'ParagraphStyleDefinition' do
    let(:library) { Uniword::Styles::StyleLibrary.load('iso_standard') }

    describe '#resolve_inheritance' do
      it 'returns properties without base style' do
        style = library.paragraph_style(:body_text)
        resolved = style.resolve_inheritance(library)

        expect(resolved[:properties]).to include(alignment: 'left')
        expect(resolved[:run_properties]).to include(font: 'Calibri')
      end

      it 'merges properties with base style' do
        # subtitle inherits from title
        style = library.paragraph_style(:subtitle)
        resolved = style.resolve_inheritance(library)

        # Should have its own spacing
        expect(resolved[:properties][:spacing_before]).to eq(120)
        # Should inherit alignment from title
        expect(resolved[:properties][:alignment]).to eq('center')
      end

      it 'merges run properties with base style' do
        # subtitle inherits from title
        style = library.paragraph_style(:subtitle)
        resolved = style.resolve_inheritance(library)

        # Should have its own size
        expect(resolved[:run_properties][:size]).to eq(28)
        # Should inherit font from title
        expect(resolved[:run_properties][:font]).to eq('Arial')
      end

      it 'overrides base properties' do
        # subtitle overrides bold from title
        style = library.paragraph_style(:subtitle)
        resolved = style.resolve_inheritance(library)

        expect(resolved[:run_properties][:bold]).to be false
      end
    end

    describe 'multi-level inheritance' do
      it 'resolves through multiple levels' do
        # heading_3 inherits from heading_2, which inherits from heading_1
        style = library.paragraph_style(:heading_3)
        resolved = style.resolve_inheritance(library)

        # Should have font from heading_1
        expect(resolved[:run_properties][:font]).to eq('Arial')
        # Should have its own outline level
        expect(resolved[:properties][:outline_level]).to eq(2)
      end
    end
  end

  describe 'CharacterStyleDefinition' do
    let(:library) { Uniword::Styles::StyleLibrary.load('iso_standard') }

    it 'returns run properties' do
      style = library.character_style(:strong)

      expect(style.run_properties[:bold]).to be true
    end

    it 'has no paragraph properties' do
      style = library.character_style(:strong)

      expect(style.properties).to be_empty
    end
  end

  describe 'ListStyleDefinition' do
    let(:library) { Uniword::Styles::StyleLibrary.load('iso_standard') }

    it 'has numbering definition' do
      style = library.list_style(:bullet_list)

      expect(style.numbering_definition).to eq(1)
    end

    it 'has levels' do
      style = library.list_style(:bullet_list)

      expect(style.levels.size).to eq(3)
    end

    it 'returns level definition' do
      style = library.list_style(:bullet_list)
      level = style.level(0)

      expect(level[:text]).to eq('•')
    end
  end

  describe 'TableStyleDefinition' do
    let(:library) { Uniword::Styles::StyleLibrary.load('iso_standard') }

    it 'has table properties' do
      style = library.table_style(:standard_table)

      expect(style.table_properties).to include(width: 5000)
    end

    it 'has cell properties' do
      style = library.table_style(:standard_table)

      expect(style.cell_properties).to include(vertical_alignment: 'top')
    end

    it 'has conditional formatting' do
      style = library.table_style(:standard_table)

      expect(style.conditional_formatting).to have_key(:first_row)
    end
  end

  describe 'SemanticStyle' do
    let(:library) { Uniword::Styles::StyleLibrary.load('iso_standard') }

    it 'has semantic type' do
      style = library.semantic_style(:term)

      expect(style.semantic_type).to eq(:term)
    end

    it 'validates semantic type' do
      expect do
        Uniword::Styles::SemanticStyle.new(
          name: 'Invalid',
          semantic: :invalid_type
        )
      end.to raise_error(ArgumentError, /Invalid semantic type/)
    end

    it 'allows valid semantic types' do
      expect do
        Uniword::Styles::SemanticStyle.new(
          name: 'Example',
          semantic: :example,
          run_properties: {}
        )
      end.not_to raise_error
    end
  end
end
