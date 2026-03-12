# frozen_string_literal: true

# Document Properties namespace
# Extended and custom document properties
# Namespace: http://schemas.openxmlformats.org/officeDocument/2006/extended-properties
# Prefix: ep:

module Uniword
  module DocumentProperties
    autoload :Application, "#{__dir__}/document_properties/application"
    autoload :AppVersion, "#{__dir__}/document_properties/app_version"
    autoload :BoolValue, "#{__dir__}/document_properties/bool_value"
    autoload :Company, "#{__dir__}/document_properties/company"
    autoload :CustomProperties, "#{__dir__}/document_properties/custom_properties"
    autoload :CustomProperty, "#{__dir__}/document_properties/custom_property"
    autoload :DocSecurity, "#{__dir__}/document_properties/doc_security"
    autoload :ExtendedProperties,
             "#{__dir__}/document_properties/extended_properties"
    autoload :FileTime, "#{__dir__}/document_properties/file_time"
    autoload :HeadingPairs, "#{__dir__}/document_properties/heading_pairs"
    autoload :HyperlinksChanged, "#{__dir__}/document_properties/hyperlinks_changed"
    autoload :I4, "#{__dir__}/document_properties/i4"
    autoload :LinksUpToDate, "#{__dir__}/document_properties/links_up_to_date"
    autoload :LpwStr, "#{__dir__}/document_properties/lpw_str"
    autoload :Manager, "#{__dir__}/document_properties/manager"
    autoload :ScaleCrop, "#{__dir__}/document_properties/scale_crop"
    autoload :SharedDoc, "#{__dir__}/document_properties/shared_doc"
    autoload :TitlesOfParts, "#{__dir__}/document_properties/titles_of_parts"
    autoload :Variant, "#{__dir__}/document_properties/variant"
    autoload :Vector, "#{__dir__}/document_properties/vector"
  end
end
