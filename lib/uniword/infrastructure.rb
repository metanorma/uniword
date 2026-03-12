# frozen_string_literal: true

module Uniword
  module Infrastructure
    autoload :ZipExtractor, "#{__dir__}/infrastructure/zip_extractor"
    autoload :ZipPackager, "#{__dir__}/infrastructure/zip_packager"
    autoload :MimeParser, "#{__dir__}/infrastructure/mime_parser"
    autoload :MimePackager, "#{__dir__}/infrastructure/mime_packager"
  end
end
