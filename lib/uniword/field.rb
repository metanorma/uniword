# frozen_string_literal: true

require "lutaml/model"

module Uniword
  # Represents a field (dynamic content like page numbers, dates, etc.)
  # Fields can be simple or complex
  class Field < Lutaml::Model::Serializable
    attribute :type, :string
    attribute :instruction, :string
    attribute :value, :string
    attribute :simple, :boolean, default: -> { true }

    # Common field types
    TYPES = {
      page: "PAGE",
      numpages: "NUMPAGES",
      date: "DATE",
      time: "TIME",
      seq: "SEQ",
      ref: "REF",
      hyperlink: "HYPERLINK"
    }.freeze

    # Create a page number field
    def self.page_number(format: "ARABIC")
      new(
        type: "PAGE",
        instruction: " PAGE \\* #{format} ",
        simple: true
      )
    end

    # Create a total pages field
    def self.total_pages(format: "ARABIC")
      new(
        type: "NUMPAGES",
        instruction: " NUMPAGES \\* #{format} ",
        simple: true
      )
    end

    # Create a date field
    def self.date(format: "M/d/yyyy")
      new(
        type: "DATE",
        instruction: " DATE \\@ \"#{format}\" ",
        simple: true
      )
    end

    # Create a sequence field (for captions)
    def self.sequence(label, format: "ARABIC")
      new(
        type: "SEQ",
        instruction: " SEQ #{label} \\* #{format} ",
        simple: false
      )
    end

    # Create a caption field
    def self.caption(label: "Figure", format: "ARABIC")
      sequence(label, format: format)
    end

    # Check if this is a simple field
    def simple?
      simple
    end

    # Check if this is a complex field
    def complex?
      !simple
    end
  end
end
