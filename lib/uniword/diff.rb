# frozen_string_literal: true

module Uniword
  # Structural comparison of DOCX documents.
  #
  # Provides LCS-based paragraph alignment and categorized diff
  # results (text, formatting, structure, metadata, styles).
  #
  # @see DocumentDiffer Main comparison engine
  # @see DiffResult Value object holding diff categories
  # @see Formatter Terminal and JSON output formatting
  module Diff
    autoload :DiffResult, "uniword/diff/diff_result"
    autoload :DocumentDiffer, "uniword/diff/document_differ"
    autoload :Formatter, "uniword/diff/formatter"
    autoload :PackageDiffer, "uniword/diff/package_differ"
    autoload :PackageDiffResult, "uniword/diff/package_diff_result"
  end
end
