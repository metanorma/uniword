# frozen_string_literal: true

# Content Types namespace
# MIME type definitions for OOXML package parts
# Namespace: http://schemas.openxmlformats.org/package/2006/content-types
# Prefix: ct: (but typically no prefix, used in [Content_Types].xml)

module Uniword
  module Generated
    module ContentTypes
      autoload :Default, File.expand_path('content_types/default', __dir__)
      autoload :Override, File.expand_path('content_types/override', __dir__)
      autoload :Types, File.expand_path('content_types/types', __dir__)
    end
  end
end