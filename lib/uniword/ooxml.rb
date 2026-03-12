# frozen_string_literal: true

# OOXML (Office Open XML) Support Module
#
# This module contains all OOXML-related classes and namespaces for
# working with Microsoft Office document formats.
#
# NOTE: The Namespaces module can now be autoloaded - it constant access is at runtime
module Uniword
  module Ooxml
    # Core OOXML packages
    autoload :DocxPackage, "#{__dir__}/ooxml/docx_package"
    autoload :DotxPackage, "#{__dir__}/ooxml/dotx_package"
    autoload :ThmxPackage, "#{__dir__}/ooxml/thmx_package"
    autoload :MhtmlPackage, "#{__dir__}/ooxml/mhtml_package"
    autoload :StylesetPackage, "#{__dir__}/ooxml/styleset_package"
    autoload :ThemePackage, "#{__dir__}/ooxml/theme_package"

    # OOXML properties
    autoload :AppProperties, "#{__dir__}/ooxml/app_properties"
    autoload :CoreProperties, "#{__dir__}/ooxml/core_properties"

    # OOXML infrastructure
    autoload :Types, "#{__dir__}/ooxml/types"
    autoload :PackageFile, "#{__dir__}/ooxml/package_file"
    autoload :ContentTypes, "#{__dir__}/content_types"

    # OOXML namespaces - autoload for runtime access
    autoload :Namespaces, "#{__dir__}/ooxml/namespaces"

    # OOXML relationships and autoload :Relationships, "#{__dir__}/ooxml/relationships"
    autoload :Schema, "#{__dir__}/ooxml/schema"
  end
end
