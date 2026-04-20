# frozen_string_literal: true

module Uniword
  module Transformation
    autoload :Transformer, "#{__dir__}/transformation/transformer"
    autoload :TransformationRule, "#{__dir__}/transformation/transformation_rule"
    autoload :NullTransformationRule, "#{__dir__}/transformation/transformation_rule"
    autoload :TransformationRuleRegistry, "#{__dir__}/transformation/transformation_rule_registry"
    autoload :RunTransformationRule, "#{__dir__}/transformation/run_transformation_rule"
    autoload :TableTransformationRule, "#{__dir__}/transformation/table_transformation_rule"
    autoload :ParagraphTransformationRule, "#{__dir__}/transformation/paragraph_transformation_rule"
    autoload :HyperlinkTransformationRule, "#{__dir__}/transformation/hyperlink_transformation_rule"
    autoload :ImageTransformationRule, "#{__dir__}/transformation/image_transformation_rule"
    autoload :OoxmlToHtmlConverter, "#{__dir__}/transformation/ooxml_to_html_converter"
    autoload :HtmlToOoxmlConverter, "#{__dir__}/transformation/html_to_ooxml_converter"
    autoload :HtmlElementBuilder, "#{__dir__}/transformation/html_element_builder"
    autoload :HtmlFormattingMapper, "#{__dir__}/transformation/html_formatting_mapper"
    autoload :OoxmlToMhtmlConverter, "#{__dir__}/transformation/ooxml_to_mhtml_converter"
    autoload :MhtmlStyleBuilder, "#{__dir__}/transformation/mhtml_style_builder"
    autoload :MhtmlElementRenderer, "#{__dir__}/transformation/mhtml_element_renderer"
    autoload :MhtmlMetadataBuilder, "#{__dir__}/transformation/mhtml_metadata_builder"
  end
end
