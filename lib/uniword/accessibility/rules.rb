# frozen_string_literal: true

module Uniword
  module Accessibility
    module Rules
      autoload :ColorUsageRule, "#{__dir__}/rules/color_usage_rule"
      autoload :ContrastRatioRule, "#{__dir__}/rules/contrast_ratio_rule"
      autoload :DescriptiveHeadingsRule,
               "#{__dir__}/rules/descriptive_headings_rule"
      autoload :DocumentTitleRule, "#{__dir__}/rules/document_title_rule"
      autoload :HeadingStructureRule, "#{__dir__}/rules/heading_structure_rule"
      autoload :ImageAltTextRule, "#{__dir__}/rules/image_alt_text_rule"
      autoload :LanguageSpecificationRule,
               "#{__dir__}/rules/language_specification_rule"
      autoload :ListStructureRule, "#{__dir__}/rules/list_structure_rule"
      autoload :ReadingOrderRule, "#{__dir__}/rules/reading_order_rule"
      autoload :TableHeadersRule, "#{__dir__}/rules/table_headers_rule"
    end
  end
end
