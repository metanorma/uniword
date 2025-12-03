= Metanorma Integration Guide

== Overview

Uniword provides seamless integration with Metanorma document workflows, supporting conversion between MHTML (`.doc`) and DOCX formats. This enables editing Metanorma-generated documents in Microsoft Word while preserving document structure and formatting.

== Converting Metanorma MHTML to DOCX

=== Basic conversion

[source,ruby]
----
require 'uniword'

# Read Metanorma-generated .doc file
doc = Uniword::DocumentFactory.from_file('metanorma_output.doc')

# Convert to DOCX
doc.save('output.docx')
----

=== Batch conversion

[source,ruby]
----
# Convert all .doc files in directory
Dir.glob('metanorma_output/**/*.doc').each do |doc_path|
  doc = Uniword::DocumentFactory.from_file(doc_path)
  docx_path = doc_path.sub('.doc', '.docx')
  doc.save(docx_path)
  puts "Converted: #{File.basename(doc_path)}"
end
----

=== Using CLI

[source,bash]
----
# Single file
uniword convert metanorma_output.doc output.docx

# With verbose output
uniword convert metanorma_output.doc output.docx --verbose
----

== Round-trip editing

=== Scenario: Edit Metanorma document in Word

[source,ruby]
----
# 1. Read original Metanorma .doc
original = Uniword::DocumentFactory.from_file('standard.doc')

# 2. Convert to DOCX for editing in Word
original.save('for_editing.docx')

# 3. After editing in Word, read back
edited = Uniword::DocumentFactory.from_file('for_editing.docx')

# 4. Convert back to .doc if needed
edited.save('edited_standard.doc')

# 5. Verify content
final = Uniword::DocumentFactory.from_file('edited_standard.doc')
puts "Preserved #{final.paragraphs.count} paragraphs"
----

== Preserving Metanorma features

=== Styles

Metanorma uses specific styles. Preserve them:

[source,ruby]
----
doc = Uniword::DocumentFactory.from_file('metanorma.doc')

# Styles are automatically preserved
expect(doc.styles_configuration.find_by_id('Heading1')).not_to be_nil

# Convert maintains styles
doc.save('output.docx')
----

=== Tables

Metanorma tables often have complex structures:

[source,ruby]
----
doc = Uniword::DocumentFactory.from_file('metanorma.doc')

# Tables preserved with all properties
doc.tables.each do |table|
  puts "Table: #{table.rows.count} rows"
  table.rows.each do |row|
    puts "  Row: #{row.cells.count} cells"
  end
end
----

=== Formatting

Text formatting (bold, italic, underline) is preserved:

[source,ruby]
----
doc = Uniword::DocumentFactory.from_file('metanorma.doc')

# Count formatted runs
bold_count = 0
doc.paragraphs.each do |para|
  para.runs.each do |run|
    bold_count += 1 if run.properties&.bold
  end
end

puts "Document contains #{bold_count} bold text runs"
----

== Known limitations

[cols="1,2,1"]
|===
| Feature | Status | Planned

| Basic text and formatting
| ✅ Fully supported
| -

| Tables
| ✅ Fully supported
| -

| Styles
| ✅ Fully supported
| -

| Math formulas (OMML)
| ⚠️ Limited support
| v1.1

| Comments
| ❌ Not supported
| v1.1

| Track changes
| ❌ Not supported
| v1.1

| Images
| ⚠️ Placeholder only
| v1.1
|===

== Troubleshooting

=== Conversion fails

* Check file is valid MHTML: `uniword info file.doc`
* Try explicit format: `Uniword::DocumentFactory.from_file(path, format: :mhtml)`

=== Content missing

* Verify extraction: Count paragraphs and tables after read
* Check for unsupported elements in source

=== Performance

* Large files (>10MB) may take 2-5 seconds
* Use streaming parser for very large files (planned)

== Testing conversion quality

=== Verify paragraph preservation

[source,ruby]
----
# Read MHTML
doc_mhtml = Uniword::DocumentFactory.from_file('input.doc', format: :mhtml)
original_count = doc_mhtml.paragraphs.count

# Convert to DOCX
doc_mhtml.save('output.docx', format: :docx)

# Read DOCX back
doc_docx = Uniword::DocumentFactory.from_file('output.docx', format: :docx)

# Verify preservation (allow small variation)
puts "Original: #{original_count} paragraphs"
puts "After conversion: #{doc_docx.paragraphs.count} paragraphs"
puts "Preservation: #{(doc_docx.paragraphs.count.to_f / original_count * 100).round(1)}%"
----

=== Verify table preservation

[source,ruby]
----
doc_mhtml = Uniword::DocumentFactory.from_file('input.doc')
original_tables = doc_mhtml.tables.count

doc_mhtml.save('output.docx')
doc_docx = Uniword::DocumentFactory.from_file('output.docx')

puts "Tables preserved: #{doc_docx.tables.count} / #{original_tables}"
----

=== Verify text content

[source,ruby]
----
doc_mhtml = Uniword::DocumentFactory.from_file('input.doc')
original_text = doc_mhtml.text

doc_mhtml.save('output.docx')
doc_docx = Uniword::DocumentFactory.from_file('output.docx')

similarity = (doc_docx.text.length.to_f / original_text.length * 100).round(1)
puts "Text preservation: #{similarity}%"
----

== Best practices

=== Always verify conversion

[source,ruby]
----
def safe_convert(input_path, output_path)
  # Read original
  doc = Uniword::DocumentFactory.from_file(input_path)
  original_para_count = doc.paragraphs.count
  original_table_count = doc.tables.count

  # Convert
  doc.save(output_path)

  # Verify
  converted = Uniword::DocumentFactory.from_file(output_path)

  # Check preservation
  para_preserved = (converted.paragraphs.count.to_f / original_para_count * 100).round(1)
  tables_preserved = converted.tables.count == original_table_count

  puts "Conversion quality:"
  puts "  Paragraphs: #{para_preserved}%"
  puts "  Tables: #{tables_preserved ? '✅' : '❌'}"

  para_preserved > 95 && tables_preserved
end
----

=== Handle errors gracefully

[source,ruby]
----
begin
  doc = Uniword::DocumentFactory.from_file('metanorma.doc')
  doc.save('output.docx')
rescue Uniword::Error => e
  puts "Conversion failed: #{e.message}"
  # Fallback handling
end
----

=== Use explicit format specification

[source,ruby]
----
# Explicit format helps avoid detection errors
doc = Uniword::DocumentFactory.from_file('document.doc', format: :mhtml)
doc.save('output.docx', format: :docx)
----

== Examples

=== Example 1: Convert ISO standard

[source,ruby]
----
require 'uniword'

# Read ISO standard MHTML
standard = Uniword::DocumentFactory.from_file('iso-rice-en.doc')

puts "Standard details:"
puts "  Paragraphs: #{standard.paragraphs.count}"
puts "  Tables: #{standard.tables.count}"
puts "  Styles: #{standard.styles_configuration.all_styles.count}"

# Convert to DOCX
standard.save('iso-rice-en.docx')

puts "Converted to DOCX successfully"
----

=== Example 2: Batch process amendments

[source,ruby]
----
require 'uniword'

amendments = Dir.glob('amendments/**/*.doc')

results = amendments.map do |path|
  doc = Uniword::DocumentFactory.from_file(path)
  output = path.sub('.doc', '.docx')

  doc.save(output)

  {
    file: File.basename(path),
    paragraphs: doc.paragraphs.count,
    tables: doc.tables.count,
    success: File.exist?(output)
  }
end

# Print summary
results.each do |r|
  status = r[:success] ? '✅' : '❌'
  puts "#{status} #{r[:file]}: #{r[:paragraphs]} paras, #{r[:tables]} tables"
end
----

=== Example 3: Quality assurance

[source,ruby]
----
require 'uniword'

def qa_conversion(input_path)
  # Read original
  original = Uniword::DocumentFactory.from_file(input_path)

  # Round-trip test
  temp_docx = 'temp.docx'
  temp_doc = 'temp.doc'

  original.save(temp_docx)
  converted = Uniword::DocumentFactory.from_file(temp_docx)
  converted.save(temp_doc)
  final = Uniword::DocumentFactory.from_file(temp_doc)

  # Compare
  {
    original_paras: original.paragraphs.count,
    final_paras: final.paragraphs.count,
    preservation: (final.paragraphs.count.to_f / original.paragraphs.count * 100).round(1),
    tables_match: original.tables.count == final.tables.count
  }
ensure
  File.delete(temp_docx) if File.exist?(temp_docx)
  File.delete(temp_doc) if File.exist?(temp_doc)
end

result = qa_conversion('metanorma_output.doc')
puts "Quality: #{result[:preservation]}% paragraphs preserved"
puts "Tables: #{result[:tables_match] ? 'Preserved' : 'Lost'}"
----

== Compatibility matrix

[cols="2,1,1,1"]
|===
| Metanorma output | Read | Write | Round-trip

| ISO standards (.doc)
| ✅
| ✅
| ✅

| IEC directives (.doc)
| ✅
| ✅
| ✅

| Technical specifications
| ✅
| ✅
| ✅

| Amendments
| ✅
| ✅
| ✅

| Guides
| ✅
| ✅
| ✅
|===

== Support

For issues with Metanorma integration:

1. Check this guide for solutions
2. Run conversion tests: `bundle exec rspec spec/compatibility/`
3. Report issues with sample files at: https://github.com/metanorma/uniword

== Related documentation

* link:../README.adoc[Uniword README]
* link:MIGRATION_FROM_HTML2DOC.md[Migration from html2doc]
* link:MIGRATION_FROM_DOCX.md[Migration from docx gem]