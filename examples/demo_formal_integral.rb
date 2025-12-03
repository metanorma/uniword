#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/uniword'

# Create document using Builder DSL
doc = Uniword::Document.new

# Apply theme from .thmx file (includes media)
doc.apply_theme_file('references/word-package/office-themes/Integral.thmx')

# Apply StyleSet (can use YAML since styles don't have media)
doc.apply_styleset('formal')

# Build content using Builder DSL
Uniword::Builder.new(doc) do |b|
  # Title Section
  b.add_paragraph('Strategic Business Analysis Report', style: 'Title')
  b.add_paragraph('Q4 2024 Performance Review', style: 'Subtitle')
  b.add_paragraph('Prepared by: Research and Analytics Division', style: 'Emphasis')
  b.add_paragraph('Date: November 1, 2024', style: 'Date')
  b.add_blank_line

  # Executive Summary
  b.add_heading('Executive Summary', level: 1)

  b.add_paragraph('Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. This comprehensive analysis examines key performance indicators, strategic initiatives, and organizational outcomes for the fourth quarter of 2024.')

  b.add_paragraph('Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. The findings demonstrate significant progress across multiple operational dimensions, with particular strengths in innovation metrics and customer satisfaction indices.')

  b.add_paragraph('Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Strategic recommendations focus on leveraging current momentum while addressing identified areas for improvement in operational efficiency and market penetration.')

  b.add_blank_line

  # Introduction
  b.add_heading('Introduction', level: 1)

  b.add_heading('Background and Context', level: 2)

  b.add_paragraph('Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nec odio praesent libero sed cursus ante dapibus diam. Sed nisi etiam rhoncus maecenas tempus tellus eget condimentum rhoncus.')

  b.add_paragraph('Pellentesque diam volutpat commodo sed egestas egestas fringilla phasellus faucibus. Scelerisque eleifend donec pretium vulputate sapien nec sagittis aliquam malesuada bibendum arcu vitae elementum curabitur vitae nunc sed velit dignissim.')

  b.add_heading('Objectives and Scope', level: 2)

  b.add_paragraph('Mauris commodo quis imperdiet massa tincidunt nunc pulvinar sapien et ligula ullamcorper malesuada proin libero nunc consequat interdum varius sit amet mattis vulputate enim nulla aliquet porttitor lacus luctus accumsan tortor posuere.')

  b.add_paragraph('Ac turpis egestas integer eget aliquet nibh praesent tristique magna sit amet purus gravida quis blandit turpis cursus in hac habitasse platea dictumst quisque sagittis purus sit amet volutpat consequat mauris nunc congue nisi vitae suscipit.')

  b.add_blank_line

  # Quote section
  b.add_paragraph('"Excellence is not a destination. (Quotation style)"', style: 'Quote')
  b.add_paragraph('"It is a continuous journey that never ends. (Intense quotation style)"',
                  style: 'Intense Quote')
  b.add_blank_line

  # Methodology
  b.add_heading('Methodology', level: 1)

  b.add_heading('Research Framework', level: 2)

  b.add_paragraph('Tellus integer feugiat scelerisque varius morbi enim nunc faucibus a pellentesque sit amet porttitor eget dolor morbi non arcu risus quis varius quam quisque id diam vel quam elementum pulvinar etiam non quam lacus suspendisse faucibus.')

  b.add_paragraph('Interdum velit laoreet id donec ultrices tincidunt arcu non sodales neque sodales ut etiam sit amet nisl purus in mollis nunc sed id semper risus in hendrerit gravida rutrum quisque non tellus orci ac auctor augue mauris augue neque gravida.')

  b.add_heading('Data Collection Methods', level: 2)

  # Bulleted list
  b.add_paragraph('The research methodology incorporated multiple data collection approaches:',
                  bold: true)

  # TODO: These have to be changed to real bulleted list items when that feature is implemented
  b.add_paragraph('• Primary quantitative surveys with stakeholder groups')
  b.add_paragraph('• Secondary analysis of existing performance databases')
  b.add_paragraph('• Qualitative interviews with key organizational leaders')
  b.add_paragraph('• Observational studies of operational processes')
  b.add_paragraph('• Comparative benchmarking against industry standards')

  b.add_blank_line

  b.add_paragraph('In sagittis dui vel nisl praesent semper feugiat nibh sed pulvinar proin gravida hendrerit lectus a molestie lorem quisque id diam convallis commodo pellentesque felis purus viverra accumsan in nisl nisi scelerisque eu ultrices vitae auctor.')

  b.add_blank_line

  # Results
  b.add_heading('Results', level: 1)

  b.add_heading('Performance Metrics Overview', level: 2)

  b.add_paragraph('Eu turpis egestas pretium aenean pharetra magna ac placerat vestibulum lectus mauris ultrices eros in cursus turpis massa tincidunt dui ut ornare lectus sit amet est placerat in egestas erat imperdiet sed euismod nisi porta lorem mollis aliquam ut porttitor leo.')

  # Table with data
  b.add_table do
    row do
      cell 'Metric', bold: true, alignment: 'center'
      cell 'Q3 2024', bold: true, alignment: 'center'
      cell 'Q4 2024', bold: true, alignment: 'center'
      cell 'Change', bold: true, alignment: 'center'
    end
    row do
      cell 'Revenue Growth (%)', bold: true
      cell '12.4', alignment: 'right'
      cell '15.7', alignment: 'right'
      cell '+3.3', alignment: 'right'
    end
    row do
      cell 'Customer Satisfaction', bold: true
      cell '87.2', alignment: 'right'
      cell '91.5', alignment: 'right'
      cell '+4.3', alignment: 'right'
    end
    row do
      cell 'Operational Efficiency', bold: true
      cell '78.9', alignment: 'right'
      cell '82.1', alignment: 'right'
      cell '+3.2', alignment: 'right'
    end
    row do
      cell 'Market Share (%)', bold: true
      cell '23.6', alignment: 'right'
      cell '25.8', alignment: 'right'
      cell '+2.2', alignment: 'right'
    end
  end

  b.add_blank_line

  b.add_paragraph('A placerat vestibulum lectus mauris ultrices eros in cursus turpis massa tincidunt dui ut ornare lectus sit amet est placerat in egestas erat imperdiet sed euismod nisi porta lorem mollis aliquam ut porttitor leo a diam sollicitudin tempor id eu nisl nunc.')

  b.add_heading('Key Findings and Analysis', level: 2)

  b.add_paragraph('Mi sit amet mauris commodo quis imperdiet massa tincidunt nunc pulvinar sapien et ligula ullamcorper malesuada proin libero nunc consequat interdum varius sit amet mattis vulputate enim nulla aliquet porttitor lacus luctus accumsan tortor posuere ac ut consequat semper.')

  b.add_paragraph('Viverra aliquet eget sit amet tellus cras adipiscing enim eu turpis egestas pretium aenean pharetra magna ac placerat vestibulum lectus mauris ultrices eros in cursus turpis massa tincidunt dui ut ornare lectus sit amet est placerat in egestas erat imperdiet sed.')

  b.add_paragraph('Euismod nisi porta lorem mollis aliquam ut porttitor leo a diam sollicitudin tempor id eu nisl nunc mi ipsum faucibus vitae aliquet nec ullamcorper sit amet risus nullam eget felis eget nunc lobortis mattis aliquam faucibus purus in massa tempor nec feugiat nisl pretium.')

  b.add_blank_line

  # Conclusion
  b.add_heading('Conclusion', level: 1)

  b.add_heading('Summary of Achievements', level: 2)

  b.add_paragraph('Fusce ut placerat orci nulla pellentesque dignissim enim sit amet venenatis urna cursus eget nunc scelerisque viverra mauris in aliquam sem fringilla ut morbi tincidunt augue interdum velit euismod in pellentesque massa placerat duis ultricies lacus sed turpis tincidunt id aliquet.')

  b.add_paragraph('Risus commodo viverra maecenas accumsan lacus vel facilisis volutpat est velit egestas dui id ornare arcu odio ut sem nulla pharetra diam sit amet nisl suscipit adipiscing bibendum est ultricies integer quis auctor elit sed vulputate mi sit amet mauris commodo.')

  b.add_heading('Strategic Recommendations', level: 2)

  b.add_paragraph('Quis imperdiet massa tincidunt nunc pulvinar sapien et ligula ullamcorper malesuada proin libero nunc consequat interdum varius sit amet mattis vulputate enim nulla aliquet porttitor lacus luctus accumsan tortor posuere ac ut consequat semper viverra nam libero justo laoreet sit.')

  b.add_paragraph('Amet cursus sit amet dictum sit amet justo donec enim diam vulputate ut pharetra sit amet aliquam id diam maecenas ultricies mi eget mauris pharetra et ultrices neque ornare aenean euismod elementum nisi quis eleifend quam adipiscing vitae proin sagittis nisl rhoncus mattis rhoncus.')

  b.add_paragraph('Urna neque viverra justo nec ultrices dui sapien eget mi proin sed libero enim sed faucibus turpis in eu mi bibendum neque egestas congue quisque egestas diam in arcu cursus euismod quis viverra nibh cras pulvinar mattis nunc sed blandit libero volutpat sed cras ornare.')
end

# Save the document
output_path = 'examples/demo_formal_integral.docx'
doc.save(output_path)

# Display statistics
puts "Document created: #{output_path}"
puts 'Theme: Integral'
puts 'StyleSet: Formal'
puts "Paragraphs: #{doc.paragraphs.count}"
puts "Tables: #{doc.tables.count}"
puts ''
puts 'Please open in Microsoft Word to view the fully styled document.'
puts 'The document demonstrates:'
puts '  • Integral theme colors and fonts'
puts '  • Formal StyleSet styling'
puts '  • Professional business document structure'
puts '  • Multiple heading levels'
puts '  • Quote styling'
puts '  • Bulleted lists'
puts '  • Data tables'
