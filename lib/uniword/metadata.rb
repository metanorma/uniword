# frozen_string_literal: true

module Uniword
  module Metadata
    autoload :Metadata, "#{__dir__}/metadata/metadata"
    autoload :MetadataExtractor, "#{__dir__}/metadata/metadata_extractor"
    autoload :MetadataIndex, "#{__dir__}/metadata/metadata_index"
    autoload :MetadataManager, "#{__dir__}/metadata/metadata_manager"
    autoload :MetadataUpdater, "#{__dir__}/metadata/metadata_updater"
    autoload :MetadataValidator, "#{__dir__}/metadata/metadata_validator"
  end
end
