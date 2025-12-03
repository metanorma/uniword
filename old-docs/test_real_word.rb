# frozen_string_literal: true

# Generate a simple doc with Word, then check its namespace declarations
require_relative 'lib/uniword'

# Create and save
doc = Uniword::Document.new
doc.add_paragraph('Test')
doc.save('test_output/simple_test.docx')

# Extract and see namespace declarations
system('cd test_output && unzip -p simple_test.docx word/document.xml 2>/dev/null | head -5')
