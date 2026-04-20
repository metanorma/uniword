# frozen_string_literal: true

module Uniword
  # Table of Contents generation and management.
  #
  # Provides a CLI-oriented API for extracting headings, generating
  # TOC entries, inserting TOC into documents, and updating existing
  # TOC fields.
  #
  # @see TocGenerator Orchestrator for TOC operations
  # @see TocEntry Value object for a single TOC heading entry
  module Toc
    autoload :TocGenerator, "uniword/toc/toc_generator"
    autoload :TocEntry, "uniword/toc/toc_entry"
  end
end
