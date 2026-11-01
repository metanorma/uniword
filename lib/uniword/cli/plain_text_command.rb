# frozen_string_literal: true

module Uniword
  module Cli
    # Mechanics for the top-level `to` / `from` CLI verbs (issue #80):
    # format validation, document loading, conversion through
    # Converter::PlainText, default output path derivation, and output
    # writing. Presentation stays in CLI so in-process specs see the
    # same output as the executable.
    module PlainTextCommand
      FORMATS = { "md" => :markdown, "adoc" => :asciidoc }.freeze

      EXTENSIONS = { markdown: ".md", asciidoc: ".adoc" }.freeze

      module_function

      # Convert a DOCX file to a plain-text format.
      #
      # @param format_key [String] "md" or "adoc"
      # @param input_path [String] path to the .docx input
      # @param strict [Boolean] fail on fidelity loss
      # @return [Converter::PlainTextResult]
      def convert_to(format_key, input_path, strict: false)
        format = normalize_format!(format_key)
        document = load_document!(input_path)
        converter = Converter::PlainText.new
        if format == :markdown
          converter.to_markdown_result(document, strict: strict)
        else
          converter.to_asciidoc_result(document, strict: strict)
        end
      end

      # Convert a plain-text file to a DocumentRoot.
      #
      # @param format_key [String] "md" or "adoc"
      # @param input_path [String] path to the .md/.adoc input
      # @param strict [Boolean] fail on fidelity loss
      # @return [Converter::PlainTextResult]
      def convert_from(format_key, input_path, strict: false)
        format = normalize_format!(format_key)
        raise FileNotFoundError.new(input_path) unless File.exist?(input_path)

        text = File.read(input_path)
        converter = Converter::PlainText.new
        if format == :markdown
          converter.from_markdown_result(text, strict: strict)
        else
          converter.from_asciidoc_result(text, strict: strict)
        end
      end

      # @param format_key [String] "md" or "adoc"
      # @return [String] the canonical file extension (".md"/".adoc")
      # @raise [UnsupportedOperationError] for unknown formats
      def extension_for(format_key)
        format = normalize_format!(format_key)
        EXTENSIONS.fetch(format)
      end

      # Default output path: the input's basename with a new
      # extension, written next to the input.
      #
      # @param input_path [String]
      # @param extension [String] e.g. ".md" or ".docx"
      # @return [String]
      def default_output(input_path, extension)
        directory = File.dirname(input_path)
        basename = File.basename(input_path, ".*")
        File.join(directory, "#{basename}#{extension}")
      end

      # Write converted text to a file, or to stdout for "-".
      #
      # @param result [Converter::PlainTextResult]
      # @param output_path [String] path or "-"
      def write_text(result, output_path)
        if output_path == "-"
          $stdout.puts result.text
        else
          File.write(output_path, result.text)
        end
      end

      def normalize_format!(format_key)
        FORMATS.fetch(format_key.to_s.downcase) do
          raise UnsupportedOperationError.new(
            "format #{format_key.inspect}",
            "supported: #{FORMATS.keys.join(', ')}",
          )
        end
      end

      def load_document!(path)
        raise FileNotFoundError.new(path) unless File.exist?(path)

        DocumentFactory.from_file(path)
      end
    end
  end
end
