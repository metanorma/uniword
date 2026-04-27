# 14: Add CLI `batch` command for multi-document processing

**Priority:** P2
**Effort:** Medium (~3 hours)
**Files:**
- `lib/uniword/cli.rb` (add command)
- `lib/uniword/batch/` (existing API)

## Problem

The `Batch::DocumentProcessor` exists in `lib/uniword/batch/` (9 files) but
has no CLI surface. Users must write Ruby code to batch-process documents.

## Proposed CLI

```bash
# Batch convert all DOCX files in a directory
uniword batch convert INPUT_DIR OUTPUT_DIR --from docx --to mhtml

# Batch validate
uniword batch validate INPUT_DIR --recursive

# Batch apply theme
uniword batch apply-theme INPUT_DIR OUTPUT_DIR --name meridian

# Batch apply styleset
uniword batch apply-styleset INPUT_DIR OUTPUT_DIR --name signature

# Options
option :recursive, aliases: "-r", desc: "Process subdirectories", type: :boolean
option :pattern, desc: "File glob pattern", default: "*.docx"
option :parallel, desc: "Number of parallel workers", type: :numeric, default: 1
option :dry_run, desc: "Show what would be done", type: :boolean
```

## Implementation

Add a `Batch` Thor subcommand in `cli.rb`:

```ruby
class Batch < Thor
  desc "convert INPUT_DIR OUTPUT_DIR", "Batch convert documents"
  option :from, required: true, desc: "Input format"
  option :to, required: true, desc: "Output format"
  option :recursive, type: :boolean, default: false
  option :pattern, default: "*.docx"
  def convert(input_dir, output_dir)
    processor = Uniword::Batch::DocumentProcessor.new(
      input_dir: input_dir,
      output_dir: output_dir,
      format: options[:from].to_sym,
      output_format: options[:to].to_sym,
      recursive: options[:recursive],
      pattern: options[:pattern],
    )
    processor.process do |input, output|
      puts "  #{File.basename(input)} -> #{File.basename(output)}"
    end
  end
end
```

Register: `register Batch, "batch", "batch", "Batch document operations"`

## Verification

```bash
bundle exec rspec spec/uniword/batch/
```
