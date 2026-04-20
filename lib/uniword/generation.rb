# frozen_string_literal: true

module Uniword
  # Document generation from structured text sources.
  #
  # Provides classes for extracting styles, mapping semantic elements
  # to OOXML style names, parsing structured text, and generating
  # styled DOCX documents.
  module Generation
    autoload :StyleExtractor, "uniword/generation/style_extractor"
    autoload :StyleMapper, "uniword/generation/style_mapper"
    autoload :StructuredTextParser,
             "uniword/generation/structured_text_parser"
    autoload :DocumentGenerator,
             "uniword/generation/document_generator"
  end
end
