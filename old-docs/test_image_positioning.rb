#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'lib/uniword'

puts 'Testing Image Positioning Feature'
puts '=' * 50

# Create a new document
doc = Uniword::Document.new

# Add a paragraph with an inline image
para1 = Uniword::Paragraph.new
para1.add_run('Text before image ')

# Create inline image (default)
inline_image = Uniword::Image.new(
  width: 914_400, # 1 inch in EMUs
  height: 914_400,
  relationship_id: 'rId1',
  alt_text: 'Inline image',
  title: 'Test Inline',
  filename: 'inline.jpg'
)
inline_image.inline = true

para1.add_run(inline_image)
para1.add_run(' text after image')
doc.body.add_paragraph(para1)

puts '✓ Created inline image'

# Add a paragraph with a floating image
para2 = Uniword::Paragraph.new
floating_image = Uniword::Image.new(
  width: 1_828_800, # 2 inches in EMUs
  height: 1_828_800,
  relationship_id: 'rId2',
  alt_text: 'Floating image',
  title: 'Test Floating',
  filename: 'floating.jpg'
)
floating_image.floating = true
floating_image.horizontal_alignment = 'right'
floating_image.vertical_alignment = 'top'
floating_image.text_wrapping = 'square'

para2.add_run(floating_image)
doc.body.add_paragraph(para2)

puts '✓ Created floating image with alignment and wrapping'

# Test serialization
serializer = Uniword::Serialization::OoxmlSerializer.new
xml = serializer.serialize(doc)

puts "\n✓ Serialization successful"

# Check for inline image elements
if xml.include?('wp:inline')
  puts '✓ Found wp:inline element for inline image'
else
  puts '✗ Missing wp:inline element'
end

# Check for anchor image elements
if xml.include?('wp:anchor')
  puts '✓ Found wp:anchor element for floating image'
else
  puts '✗ Missing wp:anchor element'
end

# Check for alignment elements
if xml.include?('<wp:align>right</wp:align>')
  puts '✓ Found horizontal alignment (right)'
else
  puts '✗ Missing horizontal alignment'
end

if xml.include?('<wp:align>top</wp:align>')
  puts '✓ Found vertical alignment (top)'
else
  puts '✗ Missing vertical alignment'
end

# Check for wrapping
if xml.include?('wp:wrapSquare')
  puts '✓ Found square text wrapping'
else
  puts '✗ Missing text wrapping'
end

# Test deserialization
deserializer = Uniword::Serialization::OoxmlDeserializer.new
doc2 = deserializer.deserialize_xml(xml)

puts "\n✓ Deserialization successful"

# Verify inline image
para1_loaded = doc2.body.elements[0]
inline_img_loaded = para1_loaded.runs.find { |r| r.is_a?(Uniword::Image) }

if inline_img_loaded
  puts '✓ Found inline image in deserialized document'

  if inline_img_loaded.inline
    puts "  ✓ Image is inline: #{inline_img_loaded.inline}"
  else
    puts '  ✗ Image should be inline but is not'
  end

  puts "  - Alt text: #{inline_img_loaded.alt_text}"
  puts "  - Title: #{inline_img_loaded.title}"
  puts "  - Width: #{inline_img_loaded.width} EMUs"
  puts "  - Height: #{inline_img_loaded.height} EMUs"
else
  puts '✗ Inline image not found in deserialized document'
end

# Verify floating image
para2_loaded = doc2.body.elements[1]
floating_img_loaded = para2_loaded.runs.find { |r| r.is_a?(Uniword::Image) }

if floating_img_loaded
  puts "\n✓ Found floating image in deserialized document"

  if floating_img_loaded.inline
    puts '  ✗ Image should be floating but is inline'
  else
    puts "  ✓ Image is not inline (floating): #{floating_img_loaded.inline}"
  end

  if floating_img_loaded.horizontal_alignment == 'right'
    puts "  ✓ Horizontal alignment preserved: #{floating_img_loaded.horizontal_alignment}"
  else
    puts "  ✗ Horizontal alignment not preserved: #{floating_img_loaded.horizontal_alignment}"
  end

  if floating_img_loaded.vertical_alignment == 'top'
    puts "  ✓ Vertical alignment preserved: #{floating_img_loaded.vertical_alignment}"
  else
    puts "  ✗ Vertical alignment not preserved: #{floating_img_loaded.vertical_alignment}"
  end

  if floating_img_loaded.text_wrapping == 'square'
    puts "  ✓ Text wrapping preserved: #{floating_img_loaded.text_wrapping}"
  else
    puts "  ✗ Text wrapping not preserved: #{floating_img_loaded.text_wrapping}"
  end

  puts "  - Alt text: #{floating_img_loaded.alt_text}"
  puts "  - Title: #{floating_img_loaded.title}"
else
  puts '✗ Floating image not found in deserialized document'
end

# Test floating setter
test_image = Uniword::Image.new
test_image.floating = true
if !test_image.inline && test_image.floating
  puts "\n✓ Floating setter works correctly"
else
  puts "\n✗ Floating setter not working"
end

puts "\n#{'=' * 50}"
puts 'Image Positioning Test Complete!'
