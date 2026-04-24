# frozen_string_literal: true

module Uniword
  module Batch
    autoload :BatchResult, "#{__dir__}/batch/batch_result"
    autoload :DocumentProcessor, "#{__dir__}/batch/document_processor"
    autoload :ProcessingStage, "#{__dir__}/batch/processing_stage"
    # Stages
    autoload :CompressImagesStage,
             "#{__dir__}/batch/stages/compress_images_stage"
    autoload :ConvertFormatStage, "#{__dir__}/batch/stages/convert_format_stage"
    autoload :NormalizeStylesStage,
             "#{__dir__}/batch/stages/normalize_styles_stage"
    autoload :QualityCheckStage, "#{__dir__}/batch/stages/quality_check_stage"
    autoload :UpdateMetadataStage,
             "#{__dir__}/batch/stages/update_metadata_stage"
    autoload :ValidateLinksStage, "#{__dir__}/batch/stages/validate_links_stage"
  end
end
