# frozen_string_literal: true

# Document Properties namespace
# Extended and custom document properties
# Namespace: http://schemas.openxmlformats.org/officeDocument/2006/extended-properties
# Prefix: ep:

module Uniword
  module Generated
    module DocumentProperties
      autoload :Application, File.expand_path('document_properties/application', __dir__)
      autoload :AppVersion, File.expand_path('document_properties/app_version', __dir__)
      autoload :BoolValue, File.expand_path('document_properties/bool_value', __dir__)
      autoload :Company, File.expand_path('document_properties/company', __dir__)
      autoload :CustomProperties, File.expand_path('document_properties/custom_properties', __dir__)
      autoload :CustomProperty, File.expand_path('document_properties/custom_property', __dir__)
      autoload :DocSecurity, File.expand_path('document_properties/doc_security', __dir__)
      autoload :ExtendedProperties, File.expand_path('document_properties/extended_properties', __dir__)
      autoload :FileTime, File.expand_path('document_properties/file_time', __dir__)
      autoload :HeadingPairs, File.expand_path('document_properties/heading_pairs', __dir__)
      autoload :HyperlinksChanged, File.expand_path('document_properties/hyperlinks_changed', __dir__)
      autoload :I4, File.expand_path('document_properties/i4', __dir__)
      autoload :LinksUpToDate, File.expand_path('document_properties/links_up_to_date', __dir__)
      autoload :LpwStr, File.expand_path('document_properties/lpw_str', __dir__)
      autoload :Manager, File.expand_path('document_properties/manager', __dir__)
      autoload :ScaleCrop, File.expand_path('document_properties/scale_crop', __dir__)
      autoload :SharedDoc, File.expand_path('document_properties/shared_doc', __dir__)
      autoload :TitlesOfParts, File.expand_path('document_properties/titles_of_parts', __dir__)
      autoload :Variant, File.expand_path('document_properties/variant', __dir__)
      autoload :Vector, File.expand_path('document_properties/vector', __dir__)
    end
  end
end