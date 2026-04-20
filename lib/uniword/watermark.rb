# frozen_string_literal: true

module Uniword
  # Watermark management for documents.
  #
  # Provides operations for adding and removing text watermarks
  # from document headers.
  module Watermark
    autoload :Manager, "uniword/watermark/manager"
  end
end
