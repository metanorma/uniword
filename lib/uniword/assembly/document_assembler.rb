# frozen_string_literal: true

# All Assembly classes autoloaded via lib/uniword/assembly.rb

module Uniword
  module Assembly
    # Main orchestrator for document assembly operations.
    #
    # Responsibility: Coordinate document assembly from components.
    # Single Responsibility: Only orchestrates, delegates to specialized classes.
    #
    # The DocumentAssembler:
    # - Loads and validates assembly manifests
    # - Coordinates component loading and merging
    # - Applies variable substitution
    # - Generates table of contents
    # - Resolves cross-references
    # - Produces final assembled document
    #
    # Architecture:
    # - DocumentAssembler (orchestrator) - this class
    # - AssemblyManifest (manifest parsing)
    # - ComponentRegistry (component management)
    # - VariableSubstitutor (variable replacement)
    # - Toc (TOC creation)
    # - CrossReferenceResolver (reference resolution)
    #
    # @example Basic usage
    #   assembler = DocumentAssembler.new(
    #     components_dir: 'components/'
    #   )
    #   doc = assembler.assemble('assembly.yml')
    #   doc.save('output.docx')
    #
    # @example With variable overrides
    #   doc = assembler.assemble('assembly.yml',
    #     variables: { version: '2.0' }
    #   )
    class DocumentAssembler
      # @return [ComponentRegistry] Component registry
      attr_reader :registry

      # @return [String] Components directory path
      attr_reader :components_dir

      # Special component marker for TOC
      TOC_COMPONENT = "__toc__"

      # Initialize document assembler.
      #
      # @param components_dir [String] Path to components directory
      # @param cache_components [Boolean] Enable component caching
      #
      # @example Create assembler
      #   assembler = DocumentAssembler.new(
      #     components_dir: 'document_components/'
      #   )
      #
      # @example Disable caching
      #   assembler = DocumentAssembler.new(
      #     components_dir: 'components/',
      #     cache_components: false
      #   )
      def initialize(components_dir:, cache_components: true)
        @components_dir = components_dir
        @registry = ComponentRegistry.new(
          components_dir,
          cache_enabled: cache_components,
        )
      end

      # Assemble document from manifest.
      #
      # @param manifest_path [String] Path to assembly.yml file
      # @param variables [Hash] Additional/override variables
      # @return [Document] Assembled document
      #
      # @example Assemble document
      #   doc = assembler.assemble('assembly.yml')
      #
      # @example With variables
      #   doc = assembler.assemble('assembly.yml',
      #     variables: { custom_var: "Value" }
      #   )
      def assemble(manifest_path, variables: {})
        # Load manifest
        manifest = AssemblyManifest.new(
          manifest_path,
          override_variables: variables,
        )

        # Create new document
        document = Wordprocessingml::DocumentRoot.new

        # Initialize processors
        substitutor = VariableSubstitutor.new(manifest.variables)
        resolver = CrossReferenceResolver.new

        # Process sections
        manifest.section_list.each do |section|
          process_section(document, section, substitutor, resolver)
        end

        # Resolve cross-references
        resolver.resolve(document)

        document
      end

      # Assemble and save document.
      #
      # @param manifest_path [String] Path to assembly.yml file
      # @param output_path [String, nil] Output file path (from manifest if nil)
      # @param variables [Hash] Additional/override variables
      # @return [String] Output file path
      #
      # @example Assemble and save
      #   path = assembler.assemble_and_save('assembly.yml')
      #
      # @example Custom output
      #   path = assembler.assemble_and_save('assembly.yml',
      #     output_path: 'custom.docx'
      #   )
      def assemble_and_save(manifest_path, output_path: nil, variables: {})
        # Load manifest to get output path
        manifest = AssemblyManifest.new(
          manifest_path,
          override_variables: variables,
        )

        # Determine output path
        output = output_path || manifest.output_path

        # Assemble document
        document = assemble(manifest_path, variables: variables)

        # Save document
        document.save(output)

        output
      end

      # Preview assembly (dry run).
      #
      # @param manifest_path [String] Path to assembly.yml file
      # @return [Hash] Assembly preview information
      #
      # @example Preview assembly
      #   info = assembler.preview('assembly.yml')
      #   puts "Components: #{info[:component_count]}"
      def preview(manifest_path)
        manifest = AssemblyManifest.new(manifest_path)

        components = []
        manifest.section_list.each do |section|
          if section["component"] == TOC_COMPONENT
            components << { type: :toc, options: section["options"] }
          elsif section["component"].include?("*")
            # Resolve wildcard
            resolved = @registry.resolve(
              section["component"],
              order: section["order"],
            )
            resolved.each do |comp|
              components << { type: :component, name: comp[:name] }
            end
          else
            components << { type: :component, name: section["component"] }
          end
        end

        {
          output_path: manifest.output_path,
          template: manifest.template_name,
          variables: manifest.variables,
          component_count: components.size,
          components: components,
        }
      end

      # Clear component cache.
      #
      # @return [void]
      def clear_cache
        @registry.clear_cache
      end

      # Get cache statistics.
      #
      # @return [Hash] Cache statistics
      def cache_stats
        @registry.cache_stats
      end

      private

      # Process individual section.
      #
      # @param document [Document] Target document
      # @param section [Hash] Section configuration
      # @param substitutor [VariableSubstitutor] Variable substitutor
      # @param resolver [CrossReferenceResolver] Cross-reference resolver
      # @return [void]
      def process_section(document, section, substitutor, _resolver)
        component_name = section["component"]
        options = section["options"]

        if component_name == TOC_COMPONENT
          # Generate and insert TOC
          insert_toc(document, options)
        elsif component_name.include?("*")
          # Resolve and insert wildcard components
          insert_wildcard_components(
            document,
            component_name,
            section["order"],
            substitutor,
          )
        else
          # Insert single component
          insert_component(document, component_name, substitutor)
        end
      end

      # Insert single component.
      #
      # @param document [Document] Target document
      # @param component_name [String] Component name
      # @param substitutor [VariableSubstitutor] Variable substitutor
      # @return [void]
      def insert_component(document, component_name, substitutor)
        # Load component
        component = @registry.get(component_name)

        # Apply variable substitution
        substitutor.substitute_document(component)

        # Merge component into document
        merge_component(document, component)
      end

      # Insert wildcard-resolved components.
      #
      # @param document [Document] Target document
      # @param pattern [String] Wildcard pattern
      # @param order [String, nil] Sort order
      # @param substitutor [VariableSubstitutor] Variable substitutor
      # @return [void]
      def insert_wildcard_components(document, pattern, order, substitutor)
        components = @registry.resolve(pattern, order: order)

        components.each do |comp|
          # Apply variable substitution
          substitutor.substitute_document(comp[:document])

          # Merge into document
          merge_component(document, comp[:document])
        end
      end

      # Insert table of contents.
      #
      # @param document [Document] Target document
      # @param options [Hash] TOC options
      # @return [void]
      def insert_toc(document, options)
        max_level = options["max_level"] || 9
        title = options["title"] || "Table of Contents"

        toc = Toc.new(
          max_level: max_level,
          title: title,
        )

        # Generate TOC paragraphs
        toc_paragraphs = toc.generate_from_document(document)

        # Insert at current position
        document.body.paragraphs.concat(toc_paragraphs)
      end

      # Merge component into document.
      #
      # @param document [Document] Target document
      # @param component [Document] Component to merge
      # @return [void]
      def merge_component(document, component)
        # Merge paragraphs
        document.body.paragraphs.concat(component.paragraphs)

        # Merge tables
        document.body.tables.concat(component.tables)
      end
    end
  end
end
