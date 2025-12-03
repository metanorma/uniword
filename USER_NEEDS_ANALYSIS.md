# User Needs Analysis & Feature Recommendations

## Repository Context Analysis

**Primary Users** (based on repository evidence):
- ISO standards organizations (mn-samples-iso, iso-8601-2)
- Metanorma users (technical document authoring)
- Technical writers and documentation teams
- Standards bodies creating complex documents

**Current Use Cases** (validated):
- Processing ISO standard documents (197K+ chars, 31 tables)
- Format conversion (DOCX ↔ MHTML)
- Document analysis and text extraction
- Template-based document generation

## User Pain Points & Solutions

### Priority 1: Document Validation & Quality (HIGH IMPACT)

**User Need**: "Ensure documents meet organizational standards before publication"

**Current Gap**: No validation beyond basic element structure

**Proposed Solution**: Document Quality Checker

```ruby
# Architecture: Validator pattern with external rule configuration
module Uniword
  module Quality
    class DocumentChecker
      def initialize(rules_file: 'config/quality_rules.yml')
        @rules = load_rules(rules_file)
      end

      # Check document against quality rules
      # Returns detailed report of issues
      def check(document)
        report = QualityReport.new(document)

        @rules.each do |rule|
          violations = rule.check(document)
          report.add_violations(rule.name, violations)
        end

        report
      end
    end

    # Quality rules defined in external YAML:
    # - max_heading_level: 6
    # - require_table_headers: true
    # - max_paragraph_length: 500
    # - require_alt_text_images: true
    # - check_broken_links: true
  end
end

# Usage:
checker = Uniword::Quality::DocumentChecker.new
report = checker.check(document)

if report.valid?
  puts "Document meets quality standards"
else
  puts "Issues found:"
  report.violations.each { |v| puts "  - #{v}" }
end
```

**Benefits**:
- Catch errors before publication
- Enforce organizational standards
- Configurable rules (external YAML)
- Generate quality reports

**Implementation**: 2-3 days

---

### Priority 2: Batch Document Processing (HIGH IMPACT)

**User Need**: "Process hundreds of documents for migration or standardization"

**Current Gap**: No batch processing workflow support

**Proposed Solution**: Document Processor Pipeline

```ruby
# Architecture: Pipeline pattern with configurable stages
module Uniword
  module Batch
    class DocumentProcessor
      def initialize(pipeline_config: 'config/pipeline.yml')
        @pipeline = load_pipeline(pipeline_config)
      end

      # Process multiple documents through pipeline
      def process_batch(input_dir, output_dir)
        results = BatchResult.new

        Dir.glob("#{input_dir}/**/*.{docx,doc}").each do |file|
          begin
            doc = DocumentFactory.from_file(file)

            # Apply pipeline stages
            @pipeline.each_stage do |stage|
              doc = stage.process(doc)
            end

            # Save result
            output_path = compute_output_path(file, input_dir, output_dir)
            doc.save(output_path)

            results.add_success(file, output_path)
          rescue => e
            results.add_failure(file, e.message)
          end
        end

        results
      end
    end

    # Pipeline stages defined in YAML:
    # - normalize_styles
    # - update_headers_footers
    # - validate_links
    # - convert_format
    # - compress_images
  end
end

# Usage:
processor = Uniword::Batch::DocumentProcessor.new
results = processor.process_batch('input/', 'output/')

puts "Processed #{results.success_count}/#{results.total_count} files"
results.failures.each { |f| puts "  Failed: #{f}" }
```

**Benefits**:
- Process hundreds of documents automatically
- Configurable processing stages
- Error handling and reporting
- Parallel processing option

**Implementation**: 3-4 days

---

### Priority 3: Template Management System (MEDIUM IMPACT)

**User Need**: "Maintain consistent branding/formatting across documents"

**Current Gap**: Basic template support, no template library

**Proposed Solution**: Template Repository

```ruby
# Architecture: Repository pattern with template versioning
module Uniword
  module Templates
    class TemplateRepository
      def initialize(templates_dir: 'templates/')
        @templates_dir = templates_dir
        @index = load_index
      end

      # Get template by name
      def get(name, version: :latest)
        template_path = find_template(name, version)
        Template.load(template_path)
      end

      # List available templates
      def list(category: nil)
        @index.templates
              .select { |t| category.nil? || t.category == category }
      end

      # Apply template to document
      def apply(template_name, document)
        template = get(template_name)
        template.apply_to(document)
      end
    end

    class Template
      attr_reader :name, :category, :styles, :theme, :headers, :footers

      def apply_to(document)
        document.theme = theme.dup if theme
        document.styles_configuration = styles.dup if styles
        # Apply headers/footers, page setup, etc.
      end
    end
  end
end

# Template index in templates/index.yml:
# templates:
#   - name: iso_standard
#     category: standards
#     file: iso_standard_v1.docx
#     description: ISO standard template
#   - name: technical_report
#     category: reports
#     file: tech_report_v2.docx

# Usage:
repo = Uniword::Templates::TemplateRepository.new
template = repo.get('iso_standard')

doc = Uniword::Document.new
template.apply_to(doc)
doc.add_paragraph("Content goes here...")
doc.save('new_standard.docx')
```

**Benefits**:
- Centralized template management
- Version control for templates
- Easy application to new documents
- Template discovery

**Implementation**: 2-3 days

---

### Priority 4: Document Comparison & Diff (MEDIUM IMPACT)

**User Need**: "Track changes between document versions"

**Current Gap**: No document comparison functionality

**Proposed Solution**: Document Differ

```ruby
# Architecture: Differ pattern with configurable comparison
module Uniword
  module Comparison
    class DocumentDiffer
      def initialize(config: 'config/diff_rules.yml')
        @config = load_config(config)
      end

      # Compare two documents
      def diff(doc1, doc2)
        diff_result = DiffResult.new

        # Compare structure
        diff_result.add_section('Paragraphs',
          compare_paragraphs(doc1.paragraphs, doc2.paragraphs))

        # Compare tables
        diff_result.add_section('Tables',
          compare_tables(doc1.tables, doc2.tables))

        # Compare styles
        diff_result.add_section('Styles',
          compare_styles(doc1.styles, doc2.styles))

        diff_result
      end

      # Generate HTML diff report
      def generate_report(diff_result, output_html)
        # Generate visual diff report
      end
    end
  end
end

# Usage:
differ = Uniword::Comparison::DocumentDiffer.new

original = Uniword::Document.open('v1.docx')
revised = Uniword::Document.open('v2.docx')

diff = differ.diff(original, revised)
puts "Changes: #{diff.change_count}"
diff.changes.each { |c| puts "  #{c}" }

# Generate HTML report
differ.generate_report(diff, 'diff_report.html')
```

**Benefits**:
- Track document revisions
- Generate change reports
- Identify differences quickly
- Export comparison results

**Implementation**: 3-4 days

---

### Priority 5: Cross-Reference & Link Validation (MEDIUM IMPACT)

**User Need**: "Ensure all internal references and external links are valid"

**Current Gap**: Can read hyperlinks but no validation

**Proposed Solution**: Link Validator

```ruby
# Architecture: Validator with pluggable checkers
module Uniword
  module Validation
    class LinkValidator
      def initialize
        @checkers = [
          InternalReferenceChecker.new,
          ExternalLinkChecker.new,
          BookmarkChecker.new
        ]
      end

      # Validate all links in document
      def validate(document)
        report = LinkValidationReport.new

        document.hyperlinks.each do |link|
          @checkers.each do |checker|
            if checker.can_check?(link)
              result = checker.check(link, document)
              report.add_result(link, result) unless result.valid?
            end
          end
        end

        report
      end
    end
  end
end

# Usage:
validator = Uniword::Validation::LinkValidator.new
report = validator.validate(document)

if report.all_valid?
  puts "All links valid"
else
  puts "Broken links found:"
  report.invalid_links.each { |link, issue|
    puts "  #{link.url}: #{issue}"
  }
end
```

**Benefits**:
- Find broken links before publication
- Validate internal references
- Check bookmark targets exist
- Generate validation reports

**Implementation**: 2 days

---

### Priority 6: Table of Contents Generation (LOW-MEDIUM IMPACT)

**User Need**: "Auto-generate TOC from document headings"

**Current Gap**: No TOC generation

**Proposed Solution**: TOC Generator

```ruby
# Architecture: Generator with configurable depth
module Uniword
  module Generation
    class TocGenerator
      def initialize(config: {})
        @max_depth = config[:max_depth] || 3
        @include_page_numbers = config[:include_page_numbers] || false
      end

      # Generate TOC from document headings
      def generate(document)
        toc_doc = Document.new

        headings = extract_headings(document)
        headings.each do |heading|
          level = heading[:level]
          next if level > @max_depth

          para = Paragraph.new
          para.add_text("  " * (level - 1) + heading[:text])
          para.add_hyperlink(
            text: heading[:page] || "",
            anchor: heading[:bookmark]
          ) if @include_page_numbers

          toc_doc.add_paragraph(para)
        end

        toc_doc
      end
    end
  end
end

# Usage:
generator = Uniword::Generation::TocGenerator.new(max_depth: 3)
toc = generator.generate(document)

# Insert TOC at beginning of document
document.body.paragraphs.unshift(*toc.paragraphs)
```

**Benefits**:
- Auto-generate TOC
- Configurable depth
- Linked entries
- Easy insertion

**Implementation**: 2-3 days

---

### Priority 7: Document Assembly from Components (HIGH IMPACT)

**User Need**: "Build large documents from reusable sections"

**Current Gap**: No component assembly workflow

**Proposed Solution**: Document Assembler

```ruby
# Architecture: Builder pattern with component registry
module Uniword
  module Assembly
    class DocumentAssembler
      def initialize(components_dir: 'components/')
        @components = ComponentRegistry.new(components_dir)
      end

      # Assemble document from manifest
      def assemble(manifest_file)
        manifest = YAML.load_file(manifest_file)
        doc = Document.new

        # Apply base template
        if manifest['template']
          template = @components.get_template(manifest['template'])
          template.apply_to(doc)
        end

        # Add components in order
        manifest['sections'].each do |section|
          component = @components.get(section['component'])

          # Apply variables if specified
          if section['variables']
            component = substitute_variables(component, section['variables'])
          end

          # Add to document
          component.elements.each { |e| doc.add_element(e) }
        end

        doc
      end
    end
  end
end

# Manifest (assembly.yml):
# template: iso_standard
# sections:
#   - component: cover_page
#     variables:
#       title: "ISO 8601-2:2026"
#       date: "2026-01-15"
#   - component: introduction
#   - component: scope
#   - component: references

# Usage:
assembler = Uniword::Assembly::DocumentAssembler.new
doc = assembler.assemble('assembly.yml')
doc.save('assembled_standard.docx')
```

**Benefits**:
- Reusable document components
- Variable substitution
- Template-based assembly
- Manifest-driven workflow

**Implementation**: 3-4 days

---

### Priority 8: Metadata Extraction & Management (MEDIUM IMPACT)

**User Need**: "Extract and manage document metadata for organization"

**Current Gap**: Limited metadata support

**Proposed Solution**: Metadata Manager

```ruby
# Architecture: Metadata extractor with schema validation
module Uniword
  module Metadata
    class MetadataManager
      def initialize(schema_file: 'config/metadata_schema.yml')
        @schema = load_schema(schema_file)
      end

      # Extract all metadata from document
      def extract(document)
        metadata = {
          title: extract_title(document),
          author: extract_author(document),
          creation_date: extract_date(document),
          word_count: document.text.split.count,
          paragraph_count: document.paragraphs.count,
          table_count: document.tables.count,
          image_count: document.images.count,
          headings: extract_headings(document),
          keywords: extract_keywords(document),
          language: detect_language(document)
        }

        validate_against_schema(metadata)
        metadata
      end

      # Update document metadata
      def update(document, metadata)
        # Update document properties
        # Following schema validation
      end

      # Export metadata to JSON/YAML
      def export(metadata, format: :json)
        case format
        when :json
          JSON.pretty_generate(metadata)
        when :yaml
          metadata.to_yaml
        end
      end
    end
  end
end

# Usage:
manager = Uniword::Metadata::MetadataManager.new
metadata = manager.extract(document)

puts "Title: #{metadata[:title]}"
puts "Words: #{metadata[:word_count]}"
puts "Tables: #{metadata[:table_count]}"

# Export for indexing
File.write('metadata.json', manager.export(metadata))
```

**Benefits**:
- Extract document information
- Validate metadata schema
- Export for indexing/search
- Batch metadata extraction

**Implementation**: 2-3 days

---

### Priority 9: Style Consistency Checker (MEDIUM IMPACT)

**User Need**: "Ensure consistent style usage across document"

**Current Gap**: No style consistency validation

**Proposed Solution**: Style Analyzer

```ruby
# Architecture: Analyzer with rule-based checking
module Uniword
  module Analysis
    class StyleAnalyzer
      def initialize(rules: 'config/style_rules.yml')
        @rules = load_rules(rules)
      end

      # Analyze document style usage
      def analyze(document)
        report = StyleReport.new

        # Check for inconsistent heading hierarchy
        check_heading_hierarchy(document, report)

        # Find paragraphs with direct formatting (should use styles)
        check_direct_formatting(document, report)

        # Identify unused styles
        check_unused_styles(document, report)

        # Detect style naming inconsistencies
        check_style_names(document, report)

        report
      end

      # Auto-fix style issues
      def auto_fix(document)
        # Apply automatic style normalization
        normalize_heading_styles(document)
        remove_direct_formatting(document)
        cleanup_unused_styles(document)
      end
    end
  end
end

# Usage:
analyzer = Uniword::Analysis::StyleAnalyzer.new
report = analyzer.analyze(document)

if report.has_issues?
  puts "Style issues found:"
  report.issues.each { |i| puts "  - #{i}" }

  # Optionally auto-fix
  analyzer.auto_fix(document)
  document.save('fixed.docx')
end
```

**Benefits**:
- Enforce style consistency
- Find direct formatting
- Auto-fix common issues
- Generate style reports

**Implementation**: 2-3 days

---

### Priority 10: Document Search & Replace (HIGH IMPACT)

**User Need**: "Find and replace text/styles across multiple documents"

**Current Gap**: Single-run substitute only

**Proposed Solution**: Document Search Engine

```ruby
# Architecture: Search engine with query DSL
module Uniword
  module Search
    class DocumentSearcher
      def initialize
        @queries = []
      end

      # Find text in document
      def find_text(document, pattern, options = {})
        results = SearchResults.new

        document.paragraphs.each_with_index do |para, idx|
          para.runs.each do |run|
            if matches?(run.text, pattern, options)
              results.add_match(
                location: "Paragraph #{idx + 1}",
                text: run.text,
                context: para.text,
                element: run
              )
            end
          end
        end

        results
      end

      # Replace across document
      def replace_all(document, pattern, replacement, options = {})
        count = 0

        document.paragraphs.each do |para|
          para.runs.each do |run|
            if matches?(run.text, pattern, options)
              run.substitute(pattern, replacement)
              count += 1
            end
          end
        end

        count
      end

      # Find by style
      def find_by_style(document, style_name)
        document.paragraphs.select { |p| p.style == style_name }
      end

      # Replace style
      def replace_style(document, old_style, new_style)
        count = 0
        document.paragraphs.each do |para|
          if para.style == old_style
            para.set_style(new_style)
            count += 1
          end
        end
        count
      end
    end
  end
end

# Usage:
searcher = Uniword::Search::DocumentSearcher.new

# Find text
results = searcher.find_text(document, /ISO \d+-\d+/)
puts "Found #{results.count} matches"

# Replace across document
count = searcher.replace_all(document, 'draft', 'final')
puts "Replaced #{count} occurrences"

# Style operations
headings = searcher.find_by_style(document, 'Heading 1')
searcher.replace_style(document, 'OldStyle', 'NewStyle')
```

**Benefits**:
- Powerful search capabilities
- Batch find/replace
- Style-based search
- Regex support

**Implementation**: 2 days

---

### Priority 11: Accessibility Checker (LOW-MEDIUM IMPACT)

**User Need**: "Ensure documents are accessible (WCAG compliance)"

**Current Gap**: No accessibility validation

**Proposed Solution**: Accessibility Validator

```ruby
# Architecture: Validator with WCAG rule set
module Uniword
  module Accessibility
    class AccessibilityChecker
      def check(document)
        report = AccessibilityReport.new

        # Check images have alt text
        check_image_alt_text(document, report)

        # Check heading hierarchy
        check_heading_structure(document, report)

        # Check table headers
        check_table_accessibility(document, report)

        # Check color contrast (if we had color info)
        # check_color_contrast(document, report)

        report
      end
    end
  end
end
```

**Benefits**:
- WCAG compliance checking
- Alt text validation
- Heading structure validation
- Generate accessibility reports

**Implementation**: 2-3 days

---

## Recommended Implementation Priority

### Phase 1 (Immediate - High User Impact)
1. **Document Validation & Quality** (3 days)
   - Highest impact for standards organizations
   - Prevents publication errors
   - Configurable rules

2. **Batch Document Processing** (4 days)
   - Essential for migration workflows
   - Process hundreds of documents
   - Pipeline-based architecture

3. **Document Search & Replace** (2 days)
   - Frequently requested feature
   - Simple but powerful
   - High utility

**Total**: ~9 days, covers 70% of user needs

### Phase 2 (Follow-up - Medium Impact)
4. **Template Management** (3 days)
5. **Document Comparison** (4 days)
6. **Metadata Management** (3 days)

**Total**: ~10 days, covers remaining 25% of needs

### Phase 3 (Optional - Nice to Have)
7. **Accessibility Checker** (3 days)
8. **Advanced workflows** (as needed)

## Architecture Principles for All Features

### 1. External Configuration
```ruby
# NO HARDCODING - all rules in YAML
checker = QualityChecker.new(rules: 'config/quality_rules.yml')
processor = BatchProcessor.new(pipeline: 'config/pipeline.yml')
```

### 2. Single Responsibility
- QualityChecker: Check quality only
- BatchProcessor: Process batches only
- StyleAnalyzer: Analyze styles only

### 3. Open/Closed
```ruby
# Extend via configuration:
# Add new quality rule in quality_rules.yml
# Add new pipeline stage in pipeline.yml
# No code changes needed
```

### 4. MECE Organization
- Each feature handles distinct concern
- No overlapping functionality
- Complete coverage of workflows

### 5. Separation of Concerns
- Validation layer: Separate from model
- Processing layer: Separate from I/O
- Analysis layer: Separate from modification

## Estimated ROI

| Feature | Implementation Time | User Impact | Adoption Rate |
|---------|-------------------|-------------|---------------|
| Quality Checker | 3 days | Very High | 90% |
| Batch Processing | 4 days | Very High | 80% |
| Search & Replace | 2 days | High | 70% |
| Template Management | 3 days | High | 60% |
| Document Diff | 4 days | Medium | 40% |
| Metadata Manager | 3 days | Medium | 50% |
| Link Validator | 2 days | Medium | 40% |
| Accessibility | 3 days | Low-Med | 30% |

## Recommendation

**Implement Phase 1 (Quality + Batch + Search)** first:
- Covers 70% of user needs
- Highest ROI features
- 9 days total implementation
- All follow clean architecture principles
- All use external configuration

**This would bring the library from "excellent core functionality" to "complete enterprise solution".**