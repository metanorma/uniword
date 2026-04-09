# frozen_string_literal: true

module Uniword
  module Assembly
    # Performs variable substitution in document text.
    #
    # Responsibility: Replace {variable} placeholders with values.
    # Single Responsibility: Only handles text substitution.
    #
    # The VariableSubstitutor:
    # - Finds {variable} placeholders in text
    # - Replaces with provided values
    # - Supports nested variables (e.g., {doc.title})
    # - Type-safe substitution with validation
    # - Preserves formatting during substitution
    #
    # @example Basic substitution
    #   sub = VariableSubstitutor.new({ title: "My Doc" })
    #   result = sub.substitute("Title: {title}")
    #   # => "Title: My Doc"
    #
    # @example Document substitution
    #   sub = VariableSubstitutor.new(variables)
    #   sub.substitute_document(document)
    class VariableSubstitutor
      # @return [Hash] Variables for substitution
      attr_reader :variables

      # Pattern to match variable placeholders
      VARIABLE_PATTERN = /\{([a-zA-Z0-9_.]+)\}/.freeze

      # Initialize substitutor with variables.
      #
      # @param variables [Hash] Variable name to value mapping
      #
      # @example Create substitutor
      #   sub = VariableSubstitutor.new({
      #     title: "ISO 8601",
      #     date: "2026-01-15"
      #   })
      def initialize(variables = {})
        @variables = normalize_variables(variables)
      end

      # Substitute variables in text.
      #
      # @param text [String] Text with {variable} placeholders
      # @return [String] Text with variables replaced
      #
      # @example Substitute in text
      #   result = sub.substitute("Title: {title}, Date: {date}")
      def substitute(text)
        return text unless text.is_a?(String)

        text.gsub(VARIABLE_PATTERN) do |_match|
          var_name = ::Regexp.last_match(1)
          resolve_variable(var_name)
        end
      end

      # Substitute variables in document.
      #
      # @param document [Document] Document to process
      # @return [Document] Document with substituted text
      #
      # @example Process document
      #   sub.substitute_document(document)
      def substitute_document(document)
        # Process all paragraphs
        document.paragraphs.each do |paragraph|
          substitute_paragraph(paragraph)
        end

        # Process sections (headers/footers)
        if document.respond_to?(:sections)
          document.sections.each do |section|
            # Process headers if section has them
            if section.respond_to?(:headers)
              section.headers.each do |header|
                header.paragraphs.each do |paragraph|
                  substitute_paragraph(paragraph)
                end
              end
            end

            # Process footers if section has them
            next unless section.respond_to?(:footers)

            section.footers.each do |footer|
              footer.paragraphs.each do |paragraph|
                substitute_paragraph(paragraph)
              end
            end
          end
        end

        document
      end

      # Add or update variable.
      #
      # @param name [String, Symbol] Variable name
      # @param value [Object] Variable value
      # @return [void]
      #
      # @example Set variable
      #   sub.set_variable(:author, "John Doe")
      def set_variable(name, value)
        @variables[normalize_key(name)] = value
      end

      # Get variable value.
      #
      # @param name [String, Symbol] Variable name
      # @return [Object, nil] Variable value
      def get_variable(name)
        resolve_variable_path(normalize_key(name))
      end

      # Check if variable is defined.
      #
      # @param name [String, Symbol] Variable name
      # @return [Boolean] True if variable exists
      def variable?(name)
        key = normalize_key(name)
        resolve_variable_path(key) != nil
      end

      # List all variables.
      #
      # @return [Array<String>] Variable names
      def variable_names
        collect_all_keys(@variables)
      end

      private

      # Normalize variables hash.
      #
      # @param vars [Hash] Variables
      # @return [Hash] Normalized variables
      def normalize_variables(vars)
        result = {}

        vars.each do |key, value|
          result[normalize_key(key)] = if value.is_a?(Hash)
                                         normalize_variables(value)
                                       else
                                         value
                                       end
        end

        result
      end

      # Normalize variable key.
      #
      # @param key [String, Symbol] Key
      # @return [String] Normalized key
      def normalize_key(key)
        key.to_s
      end

      # Resolve variable by name.
      #
      # @param name [String] Variable name (may be nested)
      # @return [String] Resolved value
      def resolve_variable(name)
        value = resolve_variable_path(name)

        if value.nil?
          # Return original placeholder if not found
          "{#{name}}"
        else
          # Convert to string
          value.to_s
        end
      end

      # Resolve nested variable path.
      #
      # @param path [String] Variable path (e.g., 'doc.title')
      # @return [Object, nil] Resolved value
      def resolve_variable_path(path)
        parts = path.split('.')
        current = @variables

        parts.each do |part|
          return nil unless current.is_a?(Hash)
          return nil unless current.key?(part)

          current = current[part]
        end

        current
      end

      # Substitute variables in paragraph.
      #
      # @param paragraph [Paragraph] Paragraph to process
      # @return [void]
      def substitute_paragraph(paragraph)
        paragraph.runs.each do |run|
          substitute_run(run)
        end
      end

      # Substitute variables in run.
      #
      # @param run [Run] Run to process
      # @return [void]
      def substitute_run(run)
        return unless run.text

        content = run.text.to_s
        run.text = substitute(content)
      end

      # Collect all keys from nested hash.
      #
      # @param hash [Hash] Hash to process
      # @param prefix [String] Key prefix
      # @return [Array<String>] All keys
      def collect_all_keys(hash, prefix = '')
        keys = []

        hash.each do |key, value|
          full_key = prefix.empty? ? key : "#{prefix}.#{key}"
          keys << full_key

          keys.concat(collect_all_keys(value, full_key)) if value.is_a?(Hash)
        end

        keys
      end
    end
  end
end
