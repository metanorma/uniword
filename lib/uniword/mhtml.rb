# frozen_string_literal: true

module Uniword
  module Mhtml
    # MHTML-specific classes (COMPLETELY SEPARATE from OOXML!)
    autoload :CssNumberFormatter, "#{__dir__}/mhtml/css_number_formatter"
    autoload :WordCss, "#{__dir__}/mhtml/word_css"
    autoload :MathConverter, "#{__dir__}/mhtml/math_converter"

    # MHTML Package and data classes
    autoload :MhtmlPackage, "#{__dir__}/mhtml/mhtml_package"
    autoload :Document, "#{__dir__}/mhtml/document"
    autoload :Theme, "#{__dir__}/mhtml/theme"
    autoload :StylesConfiguration, "#{__dir__}/mhtml/styles_configuration"
    autoload :NumberingConfiguration, "#{__dir__}/mhtml/numbering_configuration"
  end
end
