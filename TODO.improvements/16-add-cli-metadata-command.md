# 16: Add CLI `metadata` command for reading/writing metadata

**Priority:** P2
**Effort:** Small (~2 hours)
**Files:**
- `lib/uniword/cli.rb` (add command)
- `lib/uniword/metadata/` (existing API — 6 files)

## Problem

The `MetadataManager` and `MetadataExtractor` in `lib/uniword/metadata/`
provide full read/write access to document metadata (title, author, keywords,
etc.) but have no CLI surface. Users can only see basic metadata via the
`info` command, which is read-only and limited.

## Proposed CLI

```bash
# Read all metadata
uniword metadata show FILE

# Read specific fields
uniword metadata show FILE --field title,author,keywords

# Update metadata
uniword metadata set FILE --title "My Document" --author "John Doe"
uniword metadata set FILE --keywords "report,2024,Q4"

# Clear metadata
uniword metadata clear FILE --field keywords
uniword metadata clear FILE --all

# Options
option :output, desc: "Output format (terminal/json/yaml)", default: "terminal"
option :inplace, desc: "Modify file in place", type: :boolean, default: false
option :output_file, desc: "Write to different file", type: :string
```

## Implementation

```ruby
class Metadata < Thor
  desc "show FILE", "Display document metadata"
  option :field, desc: "Comma-separated field names", type: :string
  option :output, desc: "Format (terminal/json/yaml)", default: "terminal"
  def show(path)
    doc = Uniword.from_file(path)
    extractor = Uniword::Metadata::MetadataExtractor.new(doc)
    metadata = extractor.extract_all

    # Filter to requested fields
    if options[:field]
      fields = options[:field].split(",").map(&:strip)
      metadata = metadata.slice(*fields.map(&:to_sym))
    end

    case options[:output]
    when "json" then puts JSON.pretty_generate(metadata)
    when "yaml" then puts YAML.dump(metadata)
    else pretty_print_metadata(metadata)
    end
  end

  desc "set FILE", "Update document metadata"
  option :title, type: :string
  option :author, type: :string
  option :keywords, type: :string
  option :output_file, type: :string
  option :inplace, type: :boolean, default: false
  def set(path)
    doc = Uniword.from_file(path)
    manager = Uniword::Metadata::MetadataManager.new(doc)

    manager.title = options[:title] if options[:title]
    manager.author = options[:author] if options[:author]
    manager.keywords = options[:keywords] if options[:keywords]

    output = options[:output_file] || (options[:inplace] ? path : path.sub(/\.docx$/, '_updated.docx'))
    doc.to_file(output)
  end
end
```

Register: `register Metadata, "metadata", "metadata", "Read and write document metadata"`

## Verification

```bash
bundle exec rspec spec/uniword/metadata/
```
