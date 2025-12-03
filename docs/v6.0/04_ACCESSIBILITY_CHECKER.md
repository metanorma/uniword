# Feature 4: Accessibility Profile Checker

## Objective

**Goal**: Check documents for accessibility compliance with configurable rules (WCAG 2.1, Section 508, etc.)

**User Problem**:
- Standards organizations must ensure documents are accessible
- Legal requirement for government documents (Section 508)
- ISO requires accessibility for published standards
- Manual checking is time-consuming and error-prone

**Need**: Automated accessibility validation with configurable profiles

## Architecture Design

### Principle: Profile-Based Rule System

**Profiles** (external YAML configuration):
- WCAG 2.1 Level A
- WCAG 2.1 Level AA
- WCAG 2.1 Level AAA
- Section 508
- ISO Accessibility Requirements
- Custom organizational profiles

### Implementation

```ruby
module Uniword
  module Accessibility
    # Accessibility Checker - validate document accessibility
    #
    # Responsibility: Check accessibility compliance
    # Single Responsibility: Accessibility validation only
    #
    # External config: config/accessibility_profiles.yml
    #
    # Architecture:
    # - AccessibilityChecker: Orchestrator
    # - AccessibilityProfile: Profile configuration
    # - AccessibilityRule: Base class for rules
    # - AccessibilityReport: Results with recommendations
    class AccessibilityChecker
      def initialize(profile: :wcag_2_1_aa, config_file: 'config/accessibility_profiles.yml')
        @profiles = load_profiles(config_file)
        @profile = @profiles[profile]
        @rules = initialize_rules(@profile)
      end

      # Check document accessibility
      #
      # @param document [Document] Document to check
      # @return [AccessibilityReport] Detailed compliance report
      def check(document)
        report = AccessibilityReport.new(
          profile_name: @profile[:name],
          profile_level: @profile[:level]
        )

        # Run all enabled rules
        @rules.each do |rule|
          next unless rule.enabled?

          violations = rule.check(document)
          violations.each { |v| report.add_violation(v) }
        end

        report
      end

      # Quick compliance check (boolean)
      def compliant?(document)
        check(document).compliant?
      end

      private

      def initialize_rules(profile)
        [
          # WCAG 1.1.1: Non-text Content
          ImageAltTextRule.new(profile[:rules][:image_alt_text]),

          # WCAG 1.3.1: Info and Relationships
          HeadingStructureRule.new(profile[:rules][:heading_structure]),
          TableHeadersRule.new(profile[:rules][:table_headers]),
          ListStructureRule.new(profile[:rules][:list_structure]),

          # WCAG 1.3.2: Meaningful Sequence
          ReadingOrderRule.new(profile[:rules][:reading_order]),

          # WCAG 1.4.1: Use of Color
          ColorUsageRule.new(profile[:rules][:color_usage]),

          # WCAG 1.4.3: Contrast (Minimum)
          ContrastRatioRule.new(profile[:rules][:contrast_ratio]),

          # WCAG 2.4.2: Page Titled
          DocumentTitleRule.new(profile[:rules][:document_title]),

          # WCAG 2.4.6: Headings and Labels
          DescriptiveHeadingsRule.new(profile[:rules][:descriptive_headings]),

          # WCAG 3.1.1: Language of Page
          LanguageSpecificationRule.new(profile[:rules][:language_specification])
        ]
      end
    end

    # Accessibility Rule - base class
    #
    # Responsibility: Define rule interface
    # Single Responsibility: Rule interface only
    class AccessibilityRule
      attr_reader :rule_id, :wcag_criterion, :level

      def initialize(config)
        @config = config
        @rule_id = self.class.name.split('::').last.gsub('Rule', '').downcase
        @wcag_criterion = config[:wcag_criterion]
        @level = config[:level]
      end

      # Check if rule is enabled
      def enabled?
        @config.fetch(:enabled, true)
      end

      # Check document against rule
      #
      # @param document [Document] Document to check
      # @return [Array<AccessibilityViolation>] Found violations
      def check(document)
        raise NotImplementedError, "#{self.class} must implement #check"
      end

      protected

      def create_violation(message:, element:, severity:, suggestion:)
        AccessibilityViolation.new(
          rule_id: @rule_id,
          wcag_criterion: @wcag_criterion,
          level: @level,
          message: message,
          element: element,
          severity: severity,
          suggestion: suggestion
        )
      end
    end

    # WCAG 1.1.1: Images must have alt text
    class ImageAltTextRule < AccessibilityRule
      def check(document)
        violations = []

        document.images.each_with_index do |image, index|
          # Check for alt text
          if image.alt_text.nil? || image.alt_text.strip.empty?
            violations << create_violation(
              message: "Image #{index + 1} missing alternative text",
              element: image,
              severity: @config[:severity] || :error,
              suggestion: @config[:suggestion] ||
                "Add descriptive alternative text using image.alt_text = '...'"
            )
          end

          # Check alt text quality
          if @config[:check_quality] && image.alt_text
            if image.alt_text.length < @config[:min_length]
              violations << create_violation(
                message: "Image #{index + 1} has insufficient alt text (too short)",
                element: image,
                severity: :warning,
                suggestion: "Alternative text should describe the image content meaningfully"
              )
            end

            # Check for unhelpful text
            unhelpful = ['image', 'picture', 'photo', 'img']
            if unhelpful.any? { |word| image.alt_text.downcase.include?(word) }
              violations << create_violation(
                message: "Image #{index + 1} has generic alt text",
                element: image,
                severity: :warning,
                suggestion: "Describe what the image shows, not that it's an image"
              )
            end
          end
        end

        violations
      end
    end

    # WCAG 1.3.1: Tables must have headers
    class TableHeadersRule < AccessibilityRule
      def check(document)
        violations = []

        document.tables.each_with_index do |table, index|
          # Check if table has header row
          has_header = table.rows.first&.header?

          unless has_header
            violations << create_violation(
              message: "Table #{index + 1} missing header row",
              element: table,
              severity: @config[:severity] || :error,
              suggestion: "Mark first row as header: table.rows.first.header = true"
            )
          end

          # Check for caption if required
          if @config[:require_caption]
            # Tables should have captions for context
            violations << create_violation(
              message: "Table #{index + 1} missing caption",
              element: table,
              severity: :warning,
              suggestion: "Add table caption to describe the data presented"
            )
          end
        end

        violations
      end
    end

    # WCAG 1.3.1: Proper heading structure
    class HeadingStructureRule < AccessibilityRule
      def check(document)
        violations = []
        headings = extract_headings(document)

        # Check heading hierarchy
        previous_level = 0
        headings.each_with_index do |heading, index|
          level = heading[:level]

          # Headings should not skip levels
          if level > previous_level + 1
            violations << create_violation(
              message: "Heading hierarchy skip: Level #{previous_level} to #{level}",
              element: heading[:paragraph],
              severity: :error,
              suggestion: "Headings should increase by one level at a time (e.g., H1 → H2, not H1 → H3)"
            )
          end

          previous_level = level
        end

        # Check for heading before content
        if headings.empty? && document.paragraphs.count > @config[:min_paragraphs_for_heading]
          violations << create_violation(
            message: "Document lacks heading structure",
            element: document,
            severity: :warning,
            suggestion: "Add headings to structure the content for screen readers"
          )
        end

        violations
      end

      private

      def extract_headings(document)
        document.paragraphs
          .select { |p| p.style&.match(/^Heading (\d+)$/) }
          .map { |p| { level: p.style.match(/\d+/)[0].to_i, paragraph: p } }
      end
    end

    # WCAG 3.1.1: Language specified
    class LanguageSpecificationRule < AccessibilityRule
      def check(document)
        violations = []

        # Check if document language is specified
        # (would need to check document properties)
        if @config[:require_language]
          # Document should have language property set
          violations << create_violation(
            message: "Document language not specified",
            element: document,
            severity: :error,
            suggestion: "Set document language property for screen readers"
          )
        end

        violations
      end
    end

    # Accessibility Violation - individual issue
    class AccessibilityViolation
      attr_reader :rule_id, :wcag_criterion, :level, :message,
                  :element, :severity, :suggestion

      def initialize(attributes)
        @rule_id = attributes[:rule_id]
        @wcag_criterion = attributes[:wcag_criterion]
        @level = attributes[:level]
        @message = attributes[:message]
        @element = attributes[:element]
        @severity = attributes[:severity]
        @suggestion = attributes[:suggestion]
      end

      def error?
        @severity == :error
      end

      def warning?
        @severity == :warning
      end

      def info?
        @severity == :info
      end
    end

    # Accessibility Report - aggregated results
    class AccessibilityReport
      attr_reader :profile_name, :profile_level, :violations

      def initialize(profile_name:, profile_level:)
        @profile_name = profile_name
        @profile_level = profile_level
        @violations = []
      end

      def add_violation(violation)
        @violations << violation
      end

      # Check if document is compliant
      def compliant?
        errors.empty?
      end

      # Get violations by severity
      def errors
        @violations.select(&:error?)
      end

      def warnings
        @violations.select(&:warning?)
      end

      def infos
        @violations.select(&:info?)
      end

      # Summary text
      def summary
        return "✅ Document is accessible (#{@profile_name} #{@profile_level})" if compliant?

        lines = []
        lines << "❌ Document has accessibility issues (#{@profile_name} #{@profile_level}):"
        lines << "  Errors: #{errors.count} (must fix)"
        lines << "  Warnings: #{warnings.count} (should fix)"
        lines << "  Info: #{infos.count} (recommended)"
        lines << ""

        # Group by rule
        by_rule = @violations.group_by(&:rule_id)
        by_rule.each do |rule_id, rule_violations|
          lines << "#{rule_id} (#{rule_violations.count} issues):"
          rule_violations.first(3).each do |v|
            lines << "  - #{v.message}"
          end
          lines << "  ... and #{rule_violations.count - 3} more" if rule_violations.count > 3
        end

        lines.join("\n")
      end

      # Export to JSON
      def to_json
        JSON.pretty_generate(
          profile: {
            name: @profile_name,
            level: @profile_level
          },
          compliant: compliant?,
          summary: {
            total: @violations.count,
            errors: errors.count,
            warnings: warnings.count,
            infos: infos.count
          },
          violations: @violations.map { |v|
            {
              rule_id: v.rule_id,
              wcag_criterion: v.wcag_criterion,
              level: v.level,
              severity: v.severity,
              message: v.message,
              suggestion: v.suggestion
            }
          }
        )
      end

      # Export to HTML report
      def export_html(file_path)
        html = <<~HTML
          <!DOCTYPE html>
          <html>
          <head>
            <title>Accessibility Report - #{@profile_name} #{@profile_level}</title>
            <style>
              body { font-family: Arial, sans-serif; margin: 20px; }
              .compliant { color: green; }
              .non-compliant { color: red; }
              .error { background-color: #ffebee; padding: 10px; margin: 5px 0; }
              .warning { background-color: #fff3e0; padding: 10px; margin: 5px 0; }
              .info { background-color: #e3f2fd; padding: 10px; margin: 5px 0; }
            </style>
          </head>
          <body>
            <h1>Accessibility Report</h1>
            <p>Profile: <strong>#{@profile_name} #{@profile_level}</strong></p>
            <p class="#{compliant? ? 'compliant' : 'non-compliant'}">
              Status: #{compliant? ? '✅ Compliant' : '❌ Not Compliant'}
            </p>

            <h2>Summary</h2>
            <ul>
              <li>Total Issues: #{@violations.count}</li>
              <li>Errors (must fix): #{errors.count}</li>
              <li>Warnings (should fix): #{warnings.count}</li>
              <li>Info (recommended): #{infos.count}</li>
            </ul>

            <h2>Violations</h2>
            #{violations_html}
          </body>
          </html>
        HTML

        File.write(file_path, html)
      end

      private

      def violations_html
        @violations.group_by(&:rule_id).map do |rule_id, rule_violations|
          severity_class = rule_violations.first.severity
          <<~HTML
            <div class="#{severity_class}">
              <h3>#{rule_id.to_s.gsub('_', ' ').capitalize} (#{rule_violations.count} issues)</h3>
              <p><strong>WCAG:</strong> #{rule_violations.first.wcag_criterion}</p>
              <ul>
                #{rule_violations.map { |v|
                  "<li>#{v.message}<br/><em>Suggestion: #{v.suggestion}</em></li>"
                }.join("\n")}
              </ul>
            </div>
          HTML
        end.join("\n")
      end
    end

    # Accessibility Profile - configuration for profile
    class AccessibilityProfile
      attr_reader :name, :level, :rules

      def self.load(config, profile_name)
        profile_config = config[:profiles][profile_name]
        new(profile_config)
      end

      def initialize(config)
        @name = config[:name]
        @level = config[:level]
        @rules = config[:rules]
      end
    end
  end
end
```

### External Configuration (config/accessibility_profiles.yml)

```yaml
# Accessibility profile configurations
# External configuration for all accessibility rules

profiles:
  # WCAG 2.1 Level AA (most common)
  wcag_2_1_aa:
    name: "WCAG 2.1"
    level: "Level AA"

    rules:
      # 1.1.1 Non-text Content (Level A)
      image_alt_text:
        enabled: true
        wcag_criterion: "1.1.1 Non-text Content"
        level: "A"
        severity: error
        require_alt_text: true
        min_length: 10
        max_length: 150
        check_quality: true
        suggestion: "Add descriptive alternative text for images"

      # 1.3.1 Info and Relationships (Level A)
      heading_structure:
        enabled: true
        wcag_criterion: "1.3.1 Info and Relationships"
        level: "A"
        severity: error
        check_hierarchy: true
        require_h1: true
        no_level_skipping: true
        min_paragraphs_for_heading: 5
        suggestion: "Maintain proper heading hierarchy (H1 → H2 → H3, no skipping)"

      table_headers:
        enabled: true
        wcag_criterion: "1.3.1 Info and Relationships"
        level: "A"
        severity: error
        require_headers: true
        require_caption: false  # AA requirement, not A
        suggestion: "Mark first row as header for data tables"

      list_structure:
        enabled: true
        wcag_criterion: "1.3.1 Info and Relationships"
        level: "A"
        severity: warning
        check_proper_nesting: true
        max_nesting_depth: 5

      # 1.3.2 Meaningful Sequence (Level A)
      reading_order:
        enabled: true
        wcag_criterion: "1.3.2 Meaningful Sequence"
        level: "A"
        severity: warning
        check_logical_flow: true

      # 1.4.1 Use of Color (Level A)
      color_usage:
        enabled: true
        wcag_criterion: "1.4.1 Use of Color"
        level: "A"
        severity: warning
        check_color_alone: true
        require_text_indicators: true

      # 1.4.3 Contrast (Minimum) (Level AA)
      contrast_ratio:
        enabled: true
        wcag_criterion: "1.4.3 Contrast (Minimum)"
        level: "AA"
        severity: error
        min_contrast_ratio: 4.5  # 4.5:1 for normal text
        min_large_text_ratio: 3   # 3:1 for large text (18pt+)
        check_background_foreground: true

      # 2.4.2 Page Titled (Level A)
      document_title:
        enabled: true
        wcag_criterion: "2.4.2 Page Titled"
        level: "A"
        severity: error
        require_title: true
        min_title_length: 5
        suggestion: "Document must have a descriptive title"

      # 2.4.6 Headings and Labels (Level AA)
      descriptive_headings:
        enabled: true
        wcag_criterion: "2.4.6 Headings and Labels"
        level: "AA"
        severity: warning
        check_descriptiveness: true
        min_heading_length: 3

      # 3.1.1 Language of Page (Level A)
      language_specification:
        enabled: true
        wcag_criterion: "3.1.1 Language of Page"
        level: "A"
        severity: error
        require_language: true
        suggestion: "Specify document language for screen readers"

  # WCAG 2.1 Level A (minimum)
  wcag_2_1_a:
    name: "WCAG 2.1"
    level: "Level A"
    # Inherit AA rules but disable AA-specific ones
    inherits: wcag_2_1_aa
    overrides:
      contrast_ratio:
        enabled: false  # AA requirement
      descriptive_headings:
        enabled: false  # AA requirement

  # WCAG 2.1 Level AAA (enhanced)
  wcag_2_1_aaa:
    name: "WCAG 2.1"
    level: "Level AAA"
    inherits: wcag_2_1_aa
    overrides:
      contrast_ratio:
        min_contrast_ratio: 7  # Higher for AAA
        min_large_text_ratio: 4.5

  # Section 508 (US Government)
  section_508:
    name: "Section 508"
    level: "Standard"
    # Similar to WCAG 2.0 Level AA with some differences
    inherits: wcag_2_1_aa
    overrides:
      # Section 508 specific requirements

  # ISO Accessibility Requirements
  iso_accessibility:
    name: "ISO Accessibility"
    level: "Standard"
    inherits: wcag_2_1_aa
    # ISO may have additional requirements

  # Custom organizational profile
  custom:
    name: "Custom Profile"
    level: "Organization"
    # Define all rules explicitly
```

## File Structure

```
lib/uniword/accessibility/
  accessibility_checker.rb           # NEW - Main orchestrator
  accessibility_rule.rb              # NEW - Base rule class
  accessibility_profile.rb           # NEW - Profile configuration
  accessibility_report.rb            # NEW - Results aggregator
  accessibility_violation.rb         # NEW - Individual violation

  rules/
    image_alt_text_rule.rb          # NEW - WCAG 1.1.1
    heading_structure_rule.rb       # NEW - WCAG 1.3.1
    table_headers_rule.rb           # NEW - WCAG 1.3.1
    list_structure_rule.rb          # NEW - WCAG 1.3.1
    reading_order_rule.rb           # NEW - WCAG 1.3.2
    color_usage_rule.rb             # NEW - WCAG 1.4.1
    contrast_ratio_rule.rb          # NEW - WCAG 1.4.3
    document_title_rule.rb          # NEW - WCAG 2.4.2
    descriptive_headings_rule.rb    # NEW - WCAG 2.4.6
    language_specification_rule.rb  # NEW - WCAG 3.1.1

spec/uniword/accessibility/
  accessibility_checker_spec.rb      # NEW
  accessibility_profile_spec.rb      # NEW
  accessibility_report_spec.rb       # NEW

  rules/
    image_alt_text_rule_spec.rb     # NEW
    heading_structure_rule_spec.rb  # NEW
    table_headers_rule_spec.rb      # NEW
    # ... one spec file per rule

config/
  accessibility_profiles.yml         # NEW - External profiles & rules
```

## Usage Example

```ruby
# Check document accessibility
checker = Uniword::Accessibility::AccessibilityChecker.new(
  profile: :wcag_2_1_aa
)

report = checker.check(document)

puts report.summary
# Output if issues found:
# ❌ Document has accessibility issues (WCAG 2.1 Level AA):
#   Errors: 3 (must fix)
#   Warnings: 5 (should fix)
#   Info: 2 (recommended)
#
# image_alt_text (3 issues):
#   - Image 1 missing alternative text
#   - Image 5 missing alternative text
#   - Image 8 has insufficient alt text (too short)
#
# heading_structure (2 issues):
#   - Heading hierarchy skip: Level 1 to 3
#   ... and 1 more

# Export detailed report
report.export_html('accessibility_report.html')
File.write('accessibility.json', report.to_json)

# Quick check
if checker.compliant?(document)
  puts "✅ Document is accessible"
else
  puts "❌ Accessibility issues found - review report"
end

# Check against different profile
checker_508 = Uniword::Accessibility::AccessibilityChecker.new(
  profile: :section_508
)
report_508 = checker_508.check(document)
```

## Success Criteria

- [ ] AccessibilityChecker implemented
- [ ] 10 accessibility rules (WCAG coverage)
- [ ] 4 profiles (WCAG A/AA/AAA, Section 508)
- [ ] External YAML configuration
- [ ] HTML and JSON export
- [ ] Each rule has spec file
- [ ] 100% test coverage

## Timeline

**Total**: 2 weeks
- Week 1: Core (checker, profile, report, violation) + 5 rules
- Week 2: Remaining 5 rules + profiles + testing

## Architecture Benefits

✅ **MECE**: Each rule checks ONE WCAG criterion
✅ **External Config**: All profiles in YAML
✅ **Separation**: Checking ≠ Reporting ≠ Rules
✅ **Open/Closed**: Add rules/profiles via config
✅ **Single Responsibility**: One rule = one accessibility check

This provides comprehensive WCAG 2.1 compliance checking with clear, actionable recommendations.