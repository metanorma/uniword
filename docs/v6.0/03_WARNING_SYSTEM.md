# Feature 3: Warning System for Unsupported Elements

## Objective

**Goal**: Raise warnings when documents contain elements or constructs we don't understand or handle.

**User Problem**:
- User opens document with advanced features (charts, SmartArt, etc.)
- Uniword silently drops these elements during round-trip
- User loses data without knowing
- No feedback about what's not supported

**Need**: Clear warnings about unsupported features so users know what will be lost

## Architecture Design

### Principle: Comprehensive Element Tracking

**Strategy**: During deserialization, track ALL elements encountered vs elements in schema

```ruby
module Uniword
  module Warnings
    # Warning System - track and report unsupported elements
    #
    # Responsibility: Track unsupported elements during document processing
    # Single Responsibility: Warning tracking only
    #
    # External config: config/warning_rules.yml
    class WarningCollector
      def initialize(config_file: 'config/warning_rules.yml')
        @config = load_config(config_file)
        @warnings = []
        @element_counts = Hash.new(0)
      end

      # Record unsupported element
      def record_unsupported(element_tag, context:, location: nil)
        return unless @config[:enabled]

        @element_counts[element_tag] += 1

        warning = Warning.new(
          type: :unsupported_element,
          severity: determine_severity(element_tag),
          element: element_tag,
          message: "Unsupported element: #{element_tag}",
          context: context,
          location: location,
          suggestion: get_suggestion(element_tag)
        )

        @warnings << warning

        # Log if configured
        log_warning(warning) if @config[:log_warnings]
      end

      # Record unsupported attribute
      def record_unsupported_attribute(element_tag, attribute_name, context:)
        return unless @config[:enabled]

        warning = Warning.new(
          type: :unsupported_attribute,
          severity: :info,
          element: element_tag,
          attribute: attribute_name,
          message: "Unsupported attribute: #{element_tag}/@#{attribute_name}",
          context: context
        )

        @warnings << warning
      end

      # Generate warning report
      def report
        WarningReport.new(
          warnings: @warnings,
          element_counts: @element_counts,
          config: @config
        )
      end

      private

      def determine_severity(element_tag)
        # Critical: data-bearing elements
        if @config[:critical_elements].include?(element_tag)
          :error
        # Warning: formatting/structural elements
        elsif @config[:warning_elements].include?(element_tag)
          :warning
        # Info: optional/rarely-used elements
        else
          :info
        end
      end

      def get_suggestion(element_tag)
        @config[:element_suggestions][element_tag] ||
          "This element is not yet supported. Data may be lost in round-trip."
      end
    end

    # Warning - individual warning instance
    class Warning
      attr_reader :type, :severity, :element, :attribute, :message,
                  :context, :location, :suggestion

      def initialize(attributes)
        @type = attributes[:type]
        @severity = attributes[:severity]
        @element = attributes[:element]
        @attribute = attributes[:attribute]
        @message = attributes[:message]
        @context = attributes[:context]
        @location = attributes[:location]
        @suggestion = attributes[:suggestion]
      end

      # Check severity level
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

    # Warning Report - aggregated warnings
    class WarningReport
      attr_reader :warnings, :element_counts

      def initialize(warnings:, element_counts:, config:)
        @warnings = warnings
        @element_counts = element_counts
        @config = config
      end

      # Has any warnings?
      def any?
        @warnings.any?
      end

      # Get warnings by severity
      def errors
        @warnings.select(&:error?)
      end

      def warnings_only
        @warnings.select(&:warning?)
      end

      def infos
        @warnings.select(&:info?)
      end

      # Summary text
      def summary
        return "No warnings" unless any?

        lines = []
        lines << "Found #{@warnings.count} warnings:"
        lines << "  Errors: #{errors.count}"
        lines << "  Warnings: #{warnings_only.count}"
        lines << "  Info: #{infos.count}"
        lines << ""
        lines << "Unsupported elements encountered:"

        @element_counts.sort_by { |_, count| -count }.each do |element, count|
          lines << "  #{element}: #{count} occurrence(s)"
        end

        lines.join("\n")
      end

      # Export to JSON
      def to_json
        JSON.pretty_generate(
          total: @warnings.count,
          by_severity: {
            errors: errors.count,
            warnings: warnings_only.count,
            infos: infos.count
          },
          element_counts: @element_counts,
          warnings: @warnings.map { |w|
            {
              type: w.type,
              severity: w.severity,
              element: w.element,
              message: w.message,
              suggestion: w.suggestion
            }
          }
        )
      end
    end
  end
end
```

### Integration with Deserializer

```ruby
# Enhanced OoxmlDeserializer
class OoxmlDeserializer
  def initialize(warning_collector: nil)
    @warning_collector = warning_collector || Warnings::WarningCollector.new
  end

  def parse_element(xml_node)
    element_name = xml_node.name

    if @schema.has_element?(element_name)
      # Parse using schema
      parse_known_element(xml_node)
    else
      # Record warning
      @warning_collector.record_unsupported(
        element_name,
        context: "While parsing #{xml_node.parent.name}",
        location: xml_node.path
      )

      # Preserve as UnknownElement (Feature 1)
      UnknownElement.new(
        tag_name: element_name,
        raw_xml: xml_node.to_xml
      )
    end
  end

  # Get warning report after deserialization
  def warning_report
    @warning_collector.report
  end
end
```

### External Configuration (config/warning_rules.yml)

```yaml
warning_system:
  enabled: true
  log_warnings: true
  log_level: :warn

  # Critical elements (data-bearing) - severity: error
  critical_elements:
    - chart      # Charts - data visualization
    - smartArt   # SmartArt diagrams
    - sdt        # Content controls - user data
    - customXml  # Custom XML - data binding

  # Warning elements (important but not critical) - severity: warning
  warning_elements:
    - drawingML  # Complex drawings
    - vmlDrawing # Legacy drawings
    - fldSimple  # Some field types

  # Suggestions for common unsupported elements
  element_suggestions:
    chart: "Chart elements are not yet supported. The chart will be preserved but cannot be edited. Planned for v6.1."
    smartArt: "SmartArt is not yet supported. Diagram will be preserved but cannot be modified. Planned for v6.2."
    sdt: "Content controls are not yet supported. Controls will be preserved but values cannot be updated programmatically. Planned for v6.1."
    customXml: "Custom XML is not yet supported. XML data will be preserved but cannot be accessed. Planned for v6.3."

  # Reporting options
  reporting:
    group_by_element: true
    include_counts: true
    include_suggestions: true
    max_warnings: 100  # Don't spam with thousands of warnings
```

## Usage Example

```ruby
# Read document and get warnings
deserializer = OoxmlDeserializer.new
document = deserializer.deserialize(xml_content)

# Check for warnings
report = deserializer.warning_report

if report.any?
  puts report.summary
  # Output:
  # Found 15 warnings:
  #   Errors: 2
  #   Warnings: 10
  #   Info: 3
  #
  # Unsupported elements encountered:
  #   chart: 5 occurrence(s)
  #   smartArt: 2 occurrence(s)
  #   sdt: 8 occurrence(s)
end

# Save report for review
File.write('warnings.json', report.to_json)

# Fail if critical elements found
if report.errors.any?
  puts "WARNING: Document contains unsupported data-bearing elements!"
  puts "  Data may be lost in round-trip operations."
  puts "  Review warnings.json for details."
end
```

## Integration with DocumentFactory

```ruby
# Enhanced DocumentFactory with warning support
class DocumentFactory
  def self.from_file(path, format: :auto, collect_warnings: true)
    # Create warning collector if requested
    warning_collector = collect_warnings ? Warnings::WarningCollector.new : nil

    # Pass to deserializer
    handler = Formats::FormatHandlerRegistry.handler_for(format)
    handler.warning_collector = warning_collector

    document = handler.read(path)

    # Attach warning report to document
    if warning_collector
      document.instance_variable_set(:@warning_report, warning_collector.report)

      def document.warnings
        @warning_report
      end
    end

    document
  end
end

# Usage
doc = Document.open('complex.docx')
if doc.warnings&.any?
  puts "⚠️  #{doc.warnings.summary}"
end
```

## File Structure

```
lib/uniword/warnings/
  warning_collector.rb      # NEW - Tracks warnings during processing
  warning.rb               # NEW - Individual warning instance
  warning_report.rb        # NEW - Aggregated warning report

spec/uniword/warnings/
  warning_collector_spec.rb # NEW
  warning_spec.rb          # NEW
  warning_report_spec.rb   # NEW

config/
  warning_rules.yml        # NEW - External configuration
```

## Success Criteria

- [ ] WarningCollector implemented
- [ ] Warning and WarningReport classes
- [ ] Integration with OoxmlDeserializer
- [ ] External YAML configuration
- [ ] Element severity classification
- [ ] Suggestions for common elements
- [ ] Comprehensive tests
- [ ] 100% test coverage

## Timeline

**Total**: 1 week
- Days 1-2: WarningCollector, Warning, WarningReport classes
- Days 3-4: Integration with deserializer
- Days 5-7: Testing, configuration, documentation

## Architecture Benefits

✅ **Separation of Concerns**: Warning tracking ≠ deserialization
✅ **Single Responsibility**: WarningCollector only tracks warnings
✅ **External Configuration**: Severity levels and suggestions in YAML
✅ **Optional**: Can disable warning collection for performance
✅ **Non-Intrusive**: Doesn't affect document processing

This provides users with clear feedback about unsupported features without breaking document processing.