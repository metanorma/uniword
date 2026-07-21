# frozen_string_literal: true

module Uniword
  # DOCX file format namespace.
  #
  # DOCX packages contain OOXML markup wrapped in an OPC ZIP container.
  # This namespace holds DOCX-specific concerns: the package model,
  # document-level reconciliation, and user-defined requirements.
  module Docx
    autoload :IdAllocator, "#{__dir__}/docx/id_allocator"
    autoload :Part, "#{__dir__}/docx/part"
    autoload :RawPart, "#{__dir__}/docx/raw_part"
    autoload :StrippedPart, "#{__dir__}/docx/stripped_part"
    autoload :JunkClassifier, "#{__dir__}/docx/junk_classifier"
    autoload :ChartPart, "#{__dir__}/docx/chart_part"
    autoload :ImagePart, "#{__dir__}/docx/image_part"
    autoload :HeaderFooterPart, "#{__dir__}/docx/header_footer_part"
    autoload :CustomXmlItem, "#{__dir__}/docx/custom_xml_item"
    autoload :PartCollection, "#{__dir__}/docx/part_collection"
    autoload :HeaderFooterPartCollection,
             "#{__dir__}/docx/header_footer_part_collection"
    autoload :HeaderFooterView, "#{__dir__}/docx/header_footer_view"
    autoload :Package, "#{__dir__}/docx/package"
    autoload :PackageDefaults, "#{__dir__}/docx/package_defaults"
    autoload :PackageIntegrityChecker,
             "#{__dir__}/docx/package_integrity_checker"
    autoload :PackageSerialization, "#{__dir__}/docx/package_serialization"
    autoload :PartLoader, "#{__dir__}/docx/part_loader"
    autoload :Profile, "#{__dir__}/docx/profile"
    autoload :DocumentStatistics, "#{__dir__}/docx/document_statistics"
    autoload :Reconciler, "#{__dir__}/docx/reconciler"
  end
end
