# frozen_string_literal: true

# Let's create a doc with borders using Word directly and examine it
# First, check if we have any sample docx files
samples = Dir.glob('spec/fixtures/**/*.docx') + Dir.glob('examples/**/*.docx')
if samples.any?
  puts "Found sample: #{samples.first}"
  system("unzip -p '#{samples.first}' word/document.xml 2>/dev/null | xmllint --format - | head -60 | grep -A 3 'pBdr\\|shd\\|tab'")
end
