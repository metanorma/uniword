# frozen_string_literal: true

module Uniword
  module Quality
    autoload :DocumentChecker, "#{__dir__}/quality/document_checker"
    autoload :QualityReport, "#{__dir__}/quality/quality_report"
    autoload :QualityRule, "#{__dir__}/quality/quality_rule"
    # Rules
    autoload :HeadingHierarchyRule,
             "#{__dir__}/quality/rules/heading_hierarchy_rule"
    autoload :ImageAltTextRule, "#{__dir__}/quality/rules/image_alt_text_rule"
    autoload :LinkValidationRule,
             "#{__dir__}/quality/rules/link_validation_rule"
    autoload :ParagraphLengthRule,
             "#{__dir__}/quality/rules/paragraph_length_rule"
    autoload :StyleConsistencyRule,
             "#{__dir__}/quality/rules/style_consistency_rule"
    autoload :TableHeaderRule, "#{__dir__}/quality/rules/table_header_rule"
  end
end
