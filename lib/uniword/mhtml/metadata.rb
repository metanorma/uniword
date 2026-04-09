# frozen_string_literal: true

module Uniword
  module Mhtml
    module Metadata
      autoload :DocumentProperties, "#{__dir__}/metadata/document_properties"
      autoload :OfficeDocumentSettings, "#{__dir__}/metadata/office_document_settings"
      autoload :WordDocumentSettings, "#{__dir__}/metadata/word_document_settings"
      autoload :LatentStyles, "#{__dir__}/metadata/latent_styles"
    end
  end
end
