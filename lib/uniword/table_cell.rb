# frozen_string_literal: true

# Compatibility shim: Uniword::TableCell delegates to Wordprocessingml::TableCell
# The OOXML model is defined in wordprocessingml/table_cell.rb
#
# This file redefines Uniword::TableCell as a subclass of Wordprocessingml::TableCell
# to maintain additional API methods (add_text, etc.) while using the correct
# OOXML model for serialization.

# Pre-load the OOXML TableCell so we can inherit from it
require 'lutaml/model'

module Uniword
  module Wordprocessingml
    class TableCell < ::Lutaml::Model::Serializable
      # OOXML TableCell definition is in wordprocessingml/table_cell.rb
      # This stub prevents circular requires during the require_relative below
    end
  end
end

# Now load the OOXML version and subclass it
require_relative 'wordprocessingml/table_cell'

module Uniword
  # Override Uniword::TableCell to delegate to the OOXML model
  # while keeping additional API methods
  class TableCell < Wordprocessingml::TableCell
    # Add text to this cell (convenience method)
    #
    # @param text [String] Text content
    # @param properties [Hash] Optional paragraph properties
    # @return [self] For method chaining
    def add_text(text, properties: nil)
      paragraph = Paragraph.new(properties: properties)
      paragraph.add_text(text)
      add_paragraph(paragraph)
      self
    end

    # Get text content (convenience method)
    #
    # @return [String] Combined text from all paragraphs
    def text_content
      paragraphs.map(&:text).join("\n")
    end
  end
end
