# frozen_string_literal: true

module Uniword
  module Accessibility
    autoload :AccessibilityChecker, "#{__dir__}/accessibility/accessibility_checker"
    autoload :AccessibilityProfile, "#{__dir__}/accessibility/accessibility_profile"
    autoload :AccessibilityReport, "#{__dir__}/accessibility/accessibility_report"
    autoload :AccessibilityRule, "#{__dir__}/accessibility/accessibility_rule"
    autoload :AccessibilityViolation, "#{__dir__}/accessibility/accessibility_violation"
    autoload :Rules, "#{__dir__}/accessibility/rules"
  end
end
