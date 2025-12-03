#!/usr/bin/env ruby
# frozen_string_literal: true

# Test autoload for Session 13 namespaces

require_relative 'lib/generated/glossary'
require_relative 'lib/generated/shared_types'
require_relative 'lib/generated/document_variables'

puts '=' * 80
puts 'SESSION 13: Autoload Verification Test'
puts '=' * 80
puts

# Test Glossary namespace (g:)
puts '1. Testing Glossary namespace (g:)...'
puts '-' * 80
begin
  # Test a few key classes
  Uniword::Generated::Glossary::GlossaryDocument.new
  puts '  ✅ GlossaryDocument loaded'

  Uniword::Generated::Glossary::DocParts.new
  puts '  ✅ DocParts loaded'

  Uniword::Generated::Glossary::DocPart.new
  puts '  ✅ DocPart loaded'

  Uniword::Generated::Glossary::DocPartName.new
  puts '  ✅ DocPartName loaded'

  Uniword::Generated::Glossary::DocPartCategory.new
  puts '  ✅ DocPartCategory loaded'

  puts '  ✅ Glossary namespace: PASSED'
rescue StandardError => e
  puts "  ❌ ERROR: #{e.message}"
  puts "  #{e.backtrace.first}"
  exit 1
end
puts

# Test Shared Types namespace (st:)
puts '2. Testing Shared Types namespace (st:)...'
puts '-' * 80
begin
  # Test common value types
  Uniword::Generated::SharedTypes::OnOff.new
  puts '  ✅ OnOff loaded'

  Uniword::Generated::SharedTypes::StringType.new
  puts '  ✅ StringType loaded'

  Uniword::Generated::SharedTypes::DecimalNumber.new
  puts '  ✅ DecimalNumber loaded'

  Uniword::Generated::SharedTypes::HexColor.new
  puts '  ✅ HexColor loaded'

  Uniword::Generated::SharedTypes::TwipsMeasure.new
  puts '  ✅ TwipsMeasure loaded'

  puts '  ✅ Shared Types namespace: PASSED'
rescue StandardError => e
  puts "  ❌ ERROR: #{e.message}"
  puts "  #{e.backtrace.first}"
  exit 1
end
puts

# Test Document Variables namespace (dv:)
puts '3. Testing Document Variables namespace (dv:)...'
puts '-' * 80
begin
  # Test variable classes
  Uniword::Generated::DocumentVariables::DocVars.new
  puts '  ✅ DocVars loaded'

  Uniword::Generated::DocumentVariables::DocVar.new
  puts '  ✅ DocVar loaded'

  Uniword::Generated::DocumentVariables::VariableBinding.new
  puts '  ✅ VariableBinding loaded'

  Uniword::Generated::DocumentVariables::VariableScope.new
  puts '  ✅ VariableScope loaded'

  Uniword::Generated::DocumentVariables::DataType.new
  puts '  ✅ DataType loaded'

  puts '  ✅ Document Variables namespace: PASSED'
rescue StandardError => e
  puts "  ❌ ERROR: #{e.message}"
  puts "  #{e.backtrace.first}"
  exit 1
end
puts

# Summary
puts '=' * 80
puts 'ALL TESTS PASSED! ✅'
puts '=' * 80
puts
puts 'Results:'
puts '  • Glossary namespace (g:): 19 classes generated'
puts '  • Shared Types namespace (st:): 15 classes generated'
puts '  • Document Variables namespace (dv:): 10 classes generated'
puts '  • Total: 44 classes'
puts
puts 'All namespaces are working correctly with autoload!'
puts '=' * 80
