# frozen_string_literal: true

module Uniword
  module Transformation
    autoload :Transformer, "#{__dir__}/transformation/transformer"
    autoload :TransformationRule, "#{__dir__}/transformation/transformation_rule"
    autoload :TransformationRuleRegistry, "#{__dir__}/transformation/transformation_rule_registry"
    autoload :RunTransformationRule, "#{__dir__}/transformation/run_transformation_rule"
    autoload :TableTransformationRule, "#{__dir__}/transformation/table_transformation_rule"
    autoload :ParagraphTransformationRule, "#{__dir__}/transformation/paragraph_transformation_rule"
    autoload :HyperlinkTransformationRule, "#{__dir__}/transformation/hyperlink_transformation_rule"
    autoload :ImageTransformationRule, "#{__dir__}/transformation/image_transformation_rule"
  end
end
