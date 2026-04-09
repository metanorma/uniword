# frozen_string_literal: true

module Uniword
  # Writer for saving Theme instances to files.
  #
  # Responsibility: Handle theme file writing operations.
  # Follows Single Responsibility Principle - separated from Theme class.
  #
  # @example Save theme to .thmx file
  #   writer = ThemeWriter.new(theme)
  #   writer.save('output.thmx')
  #
  # @example Save with explicit format
  #   writer = ThemeWriter.new(theme)
  #   writer.save('output.thmx', format: :thmx)
  class ThemeWriter
    attr_reader :theme

    # Initialize writer with a theme.
    #
    # @param theme [Theme] The theme to write
    def initialize(theme)
      @theme = theme
    end

    # Save theme to file.
    #
    # @param path [String] Output path
    # @param format [Symbol] Format to save as (:auto, :thmx)
    # @return [void]
    def save(path, format: :auto)
      format = infer_format(path) if format == :auto

      case format
      when :thmx
        Ooxml::ThmxPackage.to_file(theme, path)
      else
        raise ArgumentError, "Unsupported format for theme: #{format}"
      end
    end

    private

    # Infer format from file extension.
    #
    # @param path [String] File path
    # @return [Symbol] Inferred format
    def infer_format(path)
      extension = File.extname(path).downcase
      case extension
      when '.thmx'
        :thmx
      else
        raise ArgumentError, "Cannot infer theme format from: #{extension}"
      end
    end
  end
end
