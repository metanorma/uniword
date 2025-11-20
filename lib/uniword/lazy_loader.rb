# frozen_string_literal: true

module Uniword
  # Module for lazy loading attributes to reduce memory footprint.
  #
  # Lazy loading delays the loading of data until it is actually needed,
  # which helps reduce memory usage for large documents.
  #
  # @example Using lazy attributes
  #   class Document
  #     extend LazyLoader
  #
  #     lazy_attr :paragraphs do
  #       # Load paragraphs only when accessed
  #       parse_paragraphs_from_xml
  #     end
  #   end
  module LazyLoader
    # Define a lazy attribute that loads only when first accessed.
    #
    # The loader block is executed once on first access, and the result
    # is cached for subsequent accesses.
    #
    # @param name [Symbol] The attribute name
    # @param loader [Proc] Block that returns the attribute value
    # @return [void]
    #
    # @example Define a lazy attribute
    #   lazy_attr :images do
    #     load_images_from_disk
    #   end
    def lazy_attr(name, &loader)
      raise ArgumentError, 'Block required for lazy_attr' unless loader

      # Define getter method
      define_method(name) do
        instance_variable = "@#{name}"

        # Return cached value if already loaded
        return instance_variable_get(instance_variable) if instance_variable_defined?(instance_variable)

        # Load and cache the value
        value = instance_exec(&loader)
        instance_variable_set(instance_variable, value)
        value
      end

      # Define predicate method to check if loaded
      define_method("#{name}_loaded?") do
        instance_variable_defined?("@#{name}")
      end

      # Define method to clear cached value
      define_method("clear_#{name}") do
        remove_instance_variable("@#{name}") if instance_variable_defined?("@#{name}")
      end
    end

    # Define a lazy collection attribute with batch loading.
    #
    # Similar to lazy_attr but optimized for collections that can be
    # loaded in batches or filtered on demand.
    #
    # @param name [Symbol] The collection attribute name
    # @param loader [Proc] Block that returns the collection
    # @return [void]
    #
    # @example Define a lazy collection
    #   lazy_collection :tables do
    #     load_tables_from_xml
    #   end
    def lazy_collection(name, &loader)
      raise ArgumentError, 'Block required for lazy_collection' unless loader

      # Define getter that returns array
      define_method(name) do
        instance_variable = "@#{name}"

        # Return cached collection if already loaded
        return instance_variable_get(instance_variable) if instance_variable_defined?(instance_variable)

        # Load and cache the collection
        collection = instance_exec(&loader)
        collection = [] if collection.nil?
        collection = Array(collection) unless collection.is_a?(Array)

        instance_variable_set(instance_variable, collection)
        collection
      end

      # Define method to check if collection is loaded
      define_method("#{name}_loaded?") do
        instance_variable_defined?("@#{name}")
      end

      # Define method to clear cached collection
      define_method("clear_#{name}") do
        remove_instance_variable("@#{name}") if instance_variable_defined?("@#{name}")
      end

      # Define method to get collection size without loading all items
      define_method("#{name}_count") do
        instance_variable = "@#{name}"
        return instance_variable_get(instance_variable).size if instance_variable_defined?(instance_variable)

        # If not loaded, try to get count without loading
        # This is a hook for subclasses to override
        send(name).size
      end
    end
  end
end