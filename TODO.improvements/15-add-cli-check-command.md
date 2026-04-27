# 15: Add CLI `check` command for accessibility/quality

**Priority:** P2
**Effort:** Small (~2 hours)
**Files:**
- `lib/uniword/cli.rb` (add command)
- `lib/uniword/accessibility/` (existing API — 16 files)
- `lib/uniword/quality/` (existing API — 9 files)

## Problem

`Accessibility::AccessibilityChecker` and `Quality::DocumentChecker` are fully
implemented but have no CLI surface. Users must write Ruby code to check
documents for accessibility and quality issues.

## Proposed CLI

```bash
# Check accessibility (WCAG, Section 508)
uniword check accessibility FILE

# Check document quality (best practices)
uniword check quality FILE

# Check both
uniword check all FILE

# Options
option :format, desc: "Output format (terminal/json)", default: "terminal"
option :severity, desc: "Minimum severity (info/warning/error/critical)", default: "warning"
option :rules, desc: "Comma-separated rule IDs to run", type: :string
```

## Implementation

Add a `Check` Thor subcommand:

```ruby
class Check < Thor
  desc "accessibility FILE", "Check document accessibility"
  option :format, desc: "Output format (terminal/json)", default: "terminal"
  option :severity, desc: "Minimum severity", default: "warning"
  def accessibility(path)
    doc = Uniword.from_file(path)
    checker = Uniword::Accessibility::AccessibilityChecker.new(doc)
    issues = checker.check

    case options[:format]
    when "json"
      puts JSON.pretty_generate(issues.map(&:to_h))
    else
      print_issues(issues, "Accessibility")
    end
  end

  desc "quality FILE", "Check document quality"
  def quality(path)
    # Similar pattern
  end

  desc "all FILE", "Run all checks"
  def all(path)
    # Run both accessibility and quality
  end
end
```

Register: `register Check, "check", "check", "Document quality and accessibility checks"`

## Verification

```bash
bundle exec rspec spec/uniword/accessibility/
bundle exec rspec spec/uniword/quality/
```
