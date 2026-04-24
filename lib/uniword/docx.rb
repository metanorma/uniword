# frozen_string_literal: true

module Uniword
  # DOCX file format namespace.
  #
  # DOCX packages contain OOXML markup wrapped in an OPC ZIP container.
  # This namespace holds DOCX-specific concerns: the package model,
  # document-level reconciliation, and user-defined requirements.
  module Docx
    autoload :Package, "#{__dir__}/docx/package"
    autoload :Profile, "#{__dir__}/docx/profile"
    autoload :DocumentStatistics, "#{__dir__}/docx/document_statistics"
    autoload :Reconciler, "#{__dir__}/docx/reconciler"
  end
end
