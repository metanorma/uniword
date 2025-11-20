# frozen_string_literal: true

require 'spec_helper'
require 'canon/rspec_matchers'

RSpec.describe 'StyleSet Round-Trip with Fixtures' do
  let(:dotx_file) { 'references/word-package/style-sets/Distinctive.dotx' }
  let(:styles_fixture) { 'spec/fixtures/stylesets/distinctive_styles.xml' }
  let(:theme_fixture) { 'spec/fixtures/stylesets/office_theme.xml' }

  describe 'Styles XML Round-Trip' do
    it 'loads .dotx, applies to document, and generates semantically equivalent XML' do
      skip 'StyleSet file not available' unless File.exist?(dotx_file)
      skip 'Fixture not available' unless File.exist?(styles_fixture)

      # Load StyleSet
      styleset = Uniword::StyleSet.from_dotx(dotx_file)

      # Apply to document
      doc = Uniword::Document.new
      styleset.apply_to(doc)

      # Generate styles.xml
      serializer = Uniword::Serialization::OoxmlSerializer.new
      generated_xml = serializer.send(:build_styles_xml, doc)

      # Read fixture
      expected_xml = File.read(styles_fixture)

      # Use Canon for semantic XML comparison
      # This compares structure and content, not formatting/ordering
      expect(generated_xml).to be_xml_equivalent_to(expected_xml)
    end
  end

  describe 'Full XML Equality' do
    it 'generates styles.xml structurally identical after canonicalization' do
      skip 'StyleSet file not available' unless File.exist?(dotx_file)
      skip 'Fixture not available' unless File.exist?(styles_fixture)

      # Load StyleSet and generate XML
      styleset = Uniword::StyleSet.from_dotx(dotx_file)
      doc = Uniword::Document.new
      styleset.apply_to(doc)

      serializer = Uniword::Serialization::OoxmlSerializer.new
      generated_xml = serializer.send(:build_styles_xml, doc)

      # Read fixture
      expected_xml = File.read(styles_fixture)

      # Canonicalize both XMLs using Canon
      # This normalizes: whitespace, attribute order, namespace declarations
      require 'canon'
      canonical_generated = Canon.format(generated_xml, :xml)
      canonical_expected = Canon.format(expected_xml, :xml)

      # Now compare canonical forms
      # Should be identical after canonicalization
      expect(canonical_generated).to eq(canonical_expected)
    end
  end
end