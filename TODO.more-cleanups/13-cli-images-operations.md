# 13: CLI `images` — extract/insert/list images in documents

**Priority:** P2
**Effort:** Small (~2 hours)
**Files:**
- `lib/uniword/cli.rb` (add `images` subcommand)
- `lib/uniword/document/image_manager.rb` (new)

## Use Case

Technical writers extract product screenshots from DOCX for reuse. Automation
engineers insert generated charts/images into documents. DevOps audits image
assets across document collections.

## Proposed CLI Syntax

```bash
# List all images with metadata
uniword images list report.docx

# Extract all images to a directory
uniword images extract report.docx --output-dir images/

# Insert an image into a document
uniword images insert report.docx output.docx --file logo.png

# Insert with positioning options
uniword images insert report.docx output.docx --file chart.png --width 6in --height 4in

# Remove an image by index
uniword images remove report.docx output.docx --index 2
```

## Implementation

### Image Manager

```ruby
module Uniword
  class Document
    class ImageManager
      def initialize(document)
        @document = document
      end

      def list
        # Extract from Package parts (word/media/image*.png, etc.)
        # Return array of { name, type, size, dimensions }
        package = @document.package
        package.image_parts.map do |part|
          {
            name: part.name,
            type: part.content_type,
            size: part.size,
          }
        end
      end

      def extract(output_dir)
        require "fileutils"
        FileUtils.mkdir_p(output_dir)
        package = @document.package
        package.image_parts.each do |part|
          path = File.join(output_dir, part.basename)
          File.binwrite(path, part.content)
        end
      end

      def insert(image_path, width: nil, height: nil)
        # Add image as a new package part
        # Create a paragraph with inline image reference
        @document
      end

      def remove(index)
        # Remove image part and its drawing reference
        @document
      end
    end
  end
end
```

### CLI Integration

Add `ImagesCLI < Thor` subcommand:

```ruby
class ImagesCLI < Thor
  desc "list FILE", "List images in document"
  option :verbose, aliases: "-v", type: :boolean, default: false
  def list(path)
    doc = DocumentFactory.from_file(path)
    images = doc.image_manager.list
    say("Images (#{images.count}):", :green)
    images.each_with_index do |img, i|
      say("  #{i + 1}. #{img[:name]} (#{img[:type]}, #{img[:size]} bytes)")
    end
  end

  desc "extract FILE", "Extract all images"
  option :output_dir, required: true, desc: "Output directory"
  def extract(path)
    doc = DocumentFactory.from_file(path)
    doc.image_manager.extract(options[:output_dir])
    say("Images extracted to #{options[:output_dir]}", :green)
  end

  desc "insert FILE OUTPUT", "Insert image"
  option :file, required: true, desc: "Image file to insert"
  option :width, desc: "Width (e.g., 6in, 15cm)"
  option :height, desc: "Height (e.g., 4in, 10cm)"
  def insert(path, output_path)
    doc = DocumentFactory.from_file(path)
    doc.image_manager.insert(options[:file], width: options[:width], height: options[:height])
    doc.save(output_path)
    say("Image inserted: #{output_path}", :green)
  end
end
```

## Key Design Decisions

1. **Package-level access**: images are ZIP parts in `word/media/`, accessed
   through the Package abstraction
2. **Extract preserves original format**: PNG stays PNG, JPEG stays JPEG
3. **Dimension parsing**: accept units like `6in`, `15cm`, `200px` with
   conversion to EMU (English Metric Units) for OOXML

## Verification

```bash
bundle exec rspec spec/uniword/document/image_manager_spec.rb
uniword images list spec/fixtures/with_images.docx
```
