# frozen_string_literal: true


module Uniword
  module Assembly
    # Manages component library with caching and wildcard resolution.
    #
    # Responsibility: Manage component files and provide efficient access.
    # Single Responsibility: Only handles component file management.
    #
    # The ComponentRegistry:
    # - Loads component files from directory
    # - Caches loaded components for performance
    # - Resolves wildcard patterns (e.g., 'clauses/*')
    # - Provides unified access to components
    #
    # @example Basic usage
    #   registry = ComponentRegistry.new('components/')
    #   component = registry.get('cover_page')
    #
    # @example Wildcard resolution
    #   registry = ComponentRegistry.new('components/')
    #   components = registry.resolve('clauses/*')
    class ComponentRegistry
      # @return [String] Base directory for components
      attr_reader :components_dir

      # @return [Hash] Cached components
      attr_reader :cache

      # Initialize registry with components directory.
      #
      # @param components_dir [String] Path to components directory
      # @param cache_enabled [Boolean] Enable component caching
      #
      # @example Create registry
      #   registry = ComponentRegistry.new('components/')
      #
      # @example Disable caching
      #   registry = ComponentRegistry.new('components/',
      #     cache_enabled: false
      #   )
      def initialize(components_dir, cache_enabled: true)
        @components_dir = File.expand_path(components_dir)
        @cache_enabled = cache_enabled
        @cache = {}

        validate_directory!
      end

      # Get component by name.
      #
      # @param name [String] Component name
      # @return [Document] Loaded component document
      #
      # @example Get component
      #   component = registry.get('cover_page')
      def get(name)
        # Check cache first
        return @cache[name] if @cache_enabled && @cache.key?(name)

        # Load component
        component = load_component(name)

        # Cache if enabled
        @cache[name] = component if @cache_enabled

        component
      end

      # Resolve wildcard pattern to list of components.
      #
      # @param pattern [String] Component pattern (e.g., 'clauses/*')
      # @param order [String, nil] Sort order ('alphabetical', 'numeric', nil)
      # @return [Array<Hash>] List of component info hashes
      #
      # @example Resolve wildcard
      #   components = registry.resolve('clauses/*')
      #
      # @example With ordering
      #   components = registry.resolve('clauses/*',
      #     order: 'alphabetical'
      #   )
      def resolve(pattern, order: nil)
        if pattern.include?('*')
          resolve_wildcard(pattern, order: order)
        else
          # Single component
          [{ name: pattern, document: get(pattern) }]
        end
      end

      # Check if component exists.
      #
      # @param name [String] Component name
      # @return [Boolean] True if component exists
      def exists?(name)
        find_component_path(name) != nil
      end

      # List all available components.
      #
      # @param pattern [String, nil] Optional glob pattern
      # @return [Array<String>] List of component names
      #
      # @example List all components
      #   names = registry.list
      #
      # @example List with pattern
      #   names = registry.list('clauses/*')
      def list(pattern = nil)
        if pattern
          resolve_pattern_to_paths(pattern).map do |path|
            extract_component_name(path)
          end
        else
          find_all_components.map do |path|
            extract_component_name(path)
          end
        end
      end

      # Clear component cache.
      #
      # @return [void]
      def clear_cache
        @cache.clear
      end

      # Get cache statistics.
      #
      # @return [Hash] Cache statistics
      def cache_stats
        {
          enabled: @cache_enabled,
          size: @cache.size,
          components: @cache.keys
        }
      end

      private

      # Validate components directory exists.
      #
      # @raise [ArgumentError] If directory doesn't exist
      def validate_directory!
        return if Dir.exist?(@components_dir)

        raise ArgumentError,
              "Components directory not found: #{@components_dir}"
      end

      # Load component document from file.
      #
      # @param name [String] Component name
      # @return [Document] Loaded document
      def load_component(name)
        path = find_component_path(name)

        raise ArgumentError, "Component not found: #{name}" unless path

        DocumentFactory.from_file(path)
      end

      # Find component file path.
      #
      # @param name [String] Component name
      # @return [String, nil] Full path or nil if not found
      def find_component_path(name)
        # Try common extensions
        extensions = ['.docx', '.doc']

        extensions.each do |ext|
          # Try as direct path
          path = File.join(@components_dir, "#{name}#{ext}")
          return path if File.exist?(path)

          # Try as nested path
          path = File.join(@components_dir, name, "component#{ext}")
          return path if File.exist?(path)
        end

        nil
      end

      # Resolve wildcard pattern to components.
      #
      # @param pattern [String] Wildcard pattern
      # @param order [String, nil] Sort order
      # @return [Array<Hash>] Component info list
      def resolve_wildcard(pattern, order: nil)
        paths = resolve_pattern_to_paths(pattern)

        # Sort if requested
        paths = sort_paths(paths, order) if order

        # Load components
        paths.map do |path|
          name = extract_component_name(path)
          {
            name: name,
            document: get(name)
          }
        end
      end

      # Resolve pattern to file paths.
      #
      # @param pattern [String] Glob pattern
      # @return [Array<String>] List of matching paths
      def resolve_pattern_to_paths(pattern)
        # Build glob pattern
        glob_pattern = File.join(@components_dir, pattern)

        # Add extension wildcards
        glob_pattern = "#{glob_pattern}*.docx" unless glob_pattern.end_with?('.docx')

        Dir.glob(glob_pattern)
      end

      # Find all component files.
      #
      # @return [Array<String>] All component paths
      def find_all_components
        Dir.glob(File.join(@components_dir, '**', '*.docx'))
      end

      # Extract component name from path.
      #
      # @param path [String] Full file path
      # @return [String] Component name
      def extract_component_name(path)
        # Get relative path from components directory
        relative = path.sub("#{@components_dir}/", '')

        # Remove extension
        relative.sub(/\.(docx|doc)$/, '')
      end

      # Sort paths by specified order.
      #
      # @param paths [Array<String>] File paths
      # @param order [String] Sort order
      # @return [Array<String>] Sorted paths
      def sort_paths(paths, order)
        case order
        when 'alphabetical'
          paths.sort
        when 'numeric'
          # Extract numbers and sort numerically
          paths.sort_by do |path|
            match = File.basename(path).match(/(\d+)/)
            match ? match[1].to_i : Float::INFINITY
          end
        else
          paths
        end
      end
    end
  end
end
