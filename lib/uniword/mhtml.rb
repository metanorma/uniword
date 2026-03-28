# frozen_string_literal: true

module Uniword
  module Mhtml
    # MHTML-specific classes (COMPLETELY SEPARATE from OOXML!)
    autoload :CssNumberFormatter, "#{__dir__}/mhtml/css_number_formatter"
    autoload :WordCss, "#{__dir__}/mhtml/word_css"
    autoload :MathConverter, "#{__dir__}/mhtml/math_converter"

    # MHTML MIME part models
    autoload :MimePart, "#{__dir__}/mhtml/mime_part"
    autoload :HtmlPart, "#{__dir__}/mhtml/html_part"
    autoload :XmlPart, "#{__dir__}/mhtml/xml_part"
    autoload :ImagePart, "#{__dir__}/mhtml/image_part"
    autoload :ThemePart, "#{__dir__}/mhtml/theme_part"
    autoload :HeaderFooterPart, "#{__dir__}/mhtml/header_footer_part"

    # MHTML namespaces
    autoload :Namespaces, "#{__dir__}/mhtml/namespaces"

    # MHTML metadata models
    autoload :Metadata, "#{__dir__}/mhtml/metadata"

    # MHTML Package and data classes
    autoload :MhtmlPackage, "#{__dir__}/mhtml/mhtml_package"
    autoload :Document, "#{__dir__}/mhtml/document"
    autoload :Theme, "#{__dir__}/mhtml/theme"
    autoload :StylesConfiguration, "#{__dir__}/mhtml/styles_configuration"
    autoload :NumberingConfiguration, "#{__dir__}/mhtml/numbering_configuration"
  end
end
