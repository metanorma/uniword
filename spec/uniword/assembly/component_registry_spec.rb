# frozen_string_literal: true

require 'spec_helper'
require 'uniword/assembly/component_registry'
require 'uniword/document'
require 'fileutils'
require 'tmpdir'

RSpec.describe Uniword::Assembly::ComponentRegistry do
  let(:temp_dir) { Dir.mktmpdir }
  let(:components_dir) { File.join(temp_dir, 'components') }

  before do
    FileUtils.mkdir_p(components_dir)

    # Create test component files
    create_component('cover_page')
    create_component('legal_notice')

    # Create nested components
    FileUtils.mkdir_p(File.join(components_dir, 'clauses'))
    create_component('clauses/clause_1')
    create_component('clauses/clause_2')
    create_component('clauses/clause_10')
  end

  after do
    FileUtils.rm_rf(temp_dir)
  end

  def create_component(name)
    path = File.join(components_dir, "#{name}.docx")
    FileUtils.mkdir_p(File.dirname(path))

    # Create minimal DOCX structure
    File.write(path, 'PK') # Minimal ZIP marker
  end

  describe '#initialize' do
    it 'creates registry with valid directory' do
      registry = described_class.new(components_dir)
      expect(registry.components_dir).to eq(File.expand_path(components_dir))
    end

    it 'raises error for non-existent directory' do
      expect {
        described_class.new('/nonexistent/path')
      }.to raise_error(ArgumentError, /not found/)
    end

    it 'enables caching by default' do
      registry = described_class.new(components_dir)
      stats = registry.cache_stats
      expect(stats[:enabled]).to be true
    end

    it 'can disable caching' do
      registry = described_class.new(components_dir, cache_enabled: false)
      stats = registry.cache_stats
      expect(stats[:enabled]).to be false
    end
  end

  describe '#exists?' do
    let(:registry) { described_class.new(components_dir) }

    it 'returns true for existing component' do
      expect(registry.exists?('cover_page')).to be true
    end

    it 'returns false for non-existent component' do
      expect(registry.exists?('nonexistent')).to be false
    end

    it 'works with nested components' do
      expect(registry.exists?('clauses/clause_1')).to be true
    end
  end

  describe '#list' do
    let(:registry) { described_class.new(components_dir) }

    it 'lists all components without pattern' do
      names = registry.list
      expect(names).to include('cover_page', 'legal_notice')
    end

    it 'lists components matching pattern' do
      names = registry.list('clauses/*')
      expect(names).to include('clauses/clause_1', 'clauses/clause_2')
      expect(names).not_to include('cover_page')
    end
  end

  describe '#resolve' do
    let(:registry) { described_class.new(components_dir) }

    it 'resolves single component' do
      allow(Uniword::DocumentFactory).to receive(:from_file)
        .and_return(Uniword::Document.new)

      components = registry.resolve('cover_page')
      expect(components.size).to eq(1)
      expect(components[0][:name]).to eq('cover_page')
    end

    it 'resolves wildcard pattern' do
      allow(Uniword::DocumentFactory).to receive(:from_file)
        .and_return(Uniword::Document.new)

      components = registry.resolve('clauses/*')
      expect(components.size).to be >= 2
      names = components.map { |c| c[:name] }
      expect(names).to include('clauses/clause_1', 'clauses/clause_2')
    end

    it 'sorts alphabetically when requested' do
      allow(Uniword::DocumentFactory).to receive(:from_file)
        .and_return(Uniword::Document.new)

      components = registry.resolve('clauses/*', order: 'alphabetical')
      names = components.map { |c| c[:name] }
      expect(names).to eq(names.sort)
    end

    it 'sorts numerically when requested' do
      allow(Uniword::DocumentFactory).to receive(:from_file)
        .and_return(Uniword::Document.new)

      components = registry.resolve('clauses/*', order: 'numeric')
      names = components.map { |c| c[:name] }

      # clause_1, clause_2, clause_10 should be in numeric order
      expect(names.index('clauses/clause_1')).to be < names.index('clauses/clause_2')
      expect(names.index('clauses/clause_2')).to be < names.index('clauses/clause_10')
    end
  end

  describe '#clear_cache' do
    let(:registry) { described_class.new(components_dir) }

    it 'clears cached components' do
      allow(Uniword::DocumentFactory).to receive(:from_file)
        .and_return(Uniword::Document.new)

      # Load component to cache it
      registry.get('cover_page')
      expect(registry.cache_stats[:size]).to eq(1)

      # Clear cache
      registry.clear_cache
      expect(registry.cache_stats[:size]).to eq(0)
    end
  end

  describe '#cache_stats' do
    let(:registry) { described_class.new(components_dir) }

    it 'returns cache statistics' do
      stats = registry.cache_stats
      expect(stats).to have_key(:enabled)
      expect(stats).to have_key(:size)
      expect(stats).to have_key(:components)
    end

    it 'tracks cached components' do
      allow(Uniword::DocumentFactory).to receive(:from_file)
        .and_return(Uniword::Document.new)

      registry.get('cover_page')
      stats = registry.cache_stats

      expect(stats[:size]).to eq(1)
      expect(stats[:components]).to include('cover_page')
    end
  end

  describe 'caching behavior' do
    it 'caches components when enabled' do
      registry = described_class.new(components_dir, cache_enabled: true)

      # Mock DocumentFactory to track calls
      call_count = 0
      allow(Uniword::DocumentFactory).to receive(:from_file) do
        call_count += 1
        Uniword::Document.new
      end

      # Get component twice
      registry.get('cover_page')
      registry.get('cover_page')

      # Should only load once
      expect(call_count).to eq(1)
    end

    it 'does not cache when disabled' do
      registry = described_class.new(components_dir, cache_enabled: false)

      # Mock DocumentFactory to track calls
      call_count = 0
      allow(Uniword::DocumentFactory).to receive(:from_file) do
        call_count += 1
        Uniword::Document.new
      end

      # Get component twice
      registry.get('cover_page')
      registry.get('cover_page')

      # Should load twice
      expect(call_count).to eq(2)
    end
  end

  describe 'error handling' do
    let(:registry) { described_class.new(components_dir) }

    it 'raises error for non-existent component' do
      expect {
        registry.get('nonexistent')
      }.to raise_error(ArgumentError, /not found/)
    end
  end
end