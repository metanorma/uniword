# frozen_string_literal: true

module Uniword
  # Images module for image management in documents.
  #
  # Provides listing, extraction, insertion, and removal of images
  # embedded in OOXML (DOCX) documents.
  #
  # @see ImageManager Orchestrator for image operations
  # @see ImageInfo Value object describing a single image
  module Images
    autoload :ImageManager, "uniword/images/image_manager"
    autoload :ImageInfo, "uniword/images/image_info"
  end
end
