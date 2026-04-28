# 14: CLI `template` — create/apply/list document templates

**Priority:** P2
**Effort:** Medium (~3 hours)
**Files:**
- `lib/uniword/cli.rb` (add `template` subcommand)
- `lib/uniword/template/template_library.rb` (new)

## Use Case

Technical writers maintain template libraries for reports, letters, memos, and
contracts. They need to create templates from existing documents, list available
templates, and apply them to new documents.

The existing `build` command already renders templates with data. This adds
template library management — creating, listing, and applying templates without
data.

## Proposed CLI Syntax

```bash
# List available templates
uniword template list

# Create a template from an existing DOCX
uniword template create report_template.docx --name "Monthly Report"

# Apply a template to create a new document
uniword template apply "Monthly Report" --output new_report.docx

# Apply with data
uniword template apply "Monthly Report" --output report.docx --data data.yml

# Show template details
uniword template show "Monthly Report"

# Import an external .dotx as template
uniword template import corporate.dotx --name "Corporate Letter"
```

## Implementation

### Template Library

```ruby
module Uniword
  module Template
    class TemplateLibrary
      TEMPLATES_DIR = File.join(Uniword.data_dir, "templates")

      def self.list
        Dir.glob(File.join(TEMPLATES_DIR, "*.yml")).map do |path|
          name = File.basename(path, ".yml")
          meta = YAML.safe_load(File.read(path))
          { name: name, description: meta["description"], created: meta["created"] }
        end
      end

      def self.create(docx_path, name:, description: nil)
        FileUtils.mkdir_p(TEMPLATES_DIR)

        # Load document and extract structure
        doc = DocumentFactory.from_file(docx_path)

        # Save template metadata + reference to DOCX
        meta = {
          name: name,
          description: description,
          created: Time.now.utc.iso8601,
          source: File.basename(docx_path),
          paragraphs: doc.paragraphs.count,
          tables: doc.tables.count,
          styles: doc.styles_configuration&.styles&.count || 0,
        }

        # Copy DOCX to templates directory
        template_docx = File.join(TEMPLATES_DIR, "#{name}.docx")
        FileUtils.cp(docx_path, template_docx)

        # Write metadata
        meta_path = File.join(TEMPLATES_DIR, "#{name}.yml")
        File.write(meta_path, YAML.dump(meta))

        { name: name, path: template_docx }
      end

      def self.apply(name, data: {}, output_path:)
        template_docx = File.join(TEMPLATES_DIR, "#{name}.docx")
        raise Error, "Template '#{name}' not found" unless File.exist?(template_docx)

        template = Template.load(template_docx)
        document = template.render(data)
        document.save(output_path)
      end
    end
  end
end
```

### CLI Integration

```ruby
class TemplateCLI < Thor
  desc "list", "List available templates"
  def list
    templates = Template::TemplateLibrary.list
    if templates.empty?
      say("No templates found. Use 'uniword template create' to create one.", :yellow)
      return
    end
    say("Templates (#{templates.count}):", :green)
    templates.each { |t| say("  - #{t[:name]}: #{t[:description] || 'No description'}") }
  end

  desc "create DOCX", "Create template from existing document"
  option :name, required: true, desc: "Template name"
  option :description, desc: "Template description"
  def create(docx_path)
    result = Template::TemplateLibrary.create(docx_path, name: options[:name],
                                                           description: options[:description])
    say("Template created: #{result[:name]}", :green)
  end

  desc "apply NAME", "Apply template to create new document"
  option :output, required: true, desc: "Output path"
  option :data, desc: "Data file (YAML/JSON)"
  def apply(name)
    data = load_data(options[:data]) if options[:data]
    Template::TemplateLibrary.apply(name, data: data, output_path: options[:output])
    say("Document created: #{options[:output]}", :green)
  end
end
```

## Key Design Decisions

1. **Template library in data dir**: templates stored in `~/.uniword/templates/`
   or equivalent, not in the gem directory
2. **YAML metadata**: each template has a companion `.yml` with description and
   stats, separate from the DOCX content
3. **Reuses Template.render**: the existing template engine handles variable
   substitution; this command manages the library aspect
4. **Create from DOCX**: any existing DOCX can become a template by adding
   `{{placeholder}}` markers

## Verification

```bash
bundle exec rspec spec/uniword/template/template_library_spec.rb
uniword template list
```
