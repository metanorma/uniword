# Performance Guide

This document describes the performance characteristics and optimizations implemented in Uniword.

## Overview

Uniword has been optimized for production use with large documents. Key optimizations include:

- **Memory Optimization**: Lazy loading, efficient object allocation, string optimization
- **Parsing Performance**: Optimized XPath usage, streaming parser for very large files
- **Serialization Performance**: Efficient string concatenation, reduced object creation
- **Caching**: Strategic caching of frequently accessed data

## Performance Characteristics

### Document Size Limits

Uniword can efficiently handle documents of the following sizes:

| Document Size | Read Time | Write Time | Memory Usage |
|--------------|-----------|------------|--------------|
| Small (10-50 paragraphs) | < 0.5s | < 0.5s | < 10 MB |
| Medium (100-200 paragraphs) | < 1.0s | < 1.0s | < 25 MB |
| Large (500-1000 paragraphs) | < 5.0s | < 5.0s | < 100 MB |
| Very Large (> 1000 paragraphs) | Use streaming parser | - | Variable |

### Tables

| Table Count | Cells per Table | Read Time | Memory Impact |
|-------------|----------------|-----------|---------------|
| 10 tables | 5x4 (20 cells) | < 0.5s | Minimal |
| 50 tables | 10x5 (50 cells) | < 2.0s | < 50 MB |
| 100+ tables | Variable | Use streaming | Consider streaming |

## Optimizations Implemented

### 1. Memory Optimization

#### Lazy Loading

Uniword uses lazy loading to delay data loading until actually needed:

```ruby
# Images are loaded only when accessed
image = doc.images.first
image.image_data # Data loaded here, not during parse

# Document elements are cached
doc.paragraphs # First access loads and caches
doc.paragraphs # Subsequent access uses cache
```

#### String Optimization

- All string literals use `frozen_string_literal: true`
- String concatenation uses arrays and `.join` instead of `<<`
- Reduces temporary string allocation by ~30-40%

Example of optimized serialization:

```ruby
# Before (slow - many temporary strings)
html = ''
elements.each { |e| html << serialize(e) }

# After (fast - single join operation)
html = elements.map { |e| serialize(e) }.join
```

#### Object Pooling

Frequently created objects are reused where appropriate:

- Text element caching in table cells
- Paragraph/table collection caching in Document
- Property object reuse

### 2. Parsing Performance

#### XPath Optimization

The deserializer has been optimized to minimize XPath queries:

```ruby
# Before (slow - multiple XPath calls)
body_node.xpath('./w:p', NAMESPACES).each { ... }
body_node.xpath('./w:tbl', NAMESPACES).each { ... }

# After (fast - single iteration)
body_node.element_children.each do |child|
  case child.name
  when 'p' then parse_paragraph(child)
  when 'tbl' then parse_table(child)
  end
end
```

Performance improvement: **~2x faster** parsing for large documents.

#### Streaming Parser

For very large documents (> 10 MB), use the streaming parser:

```ruby
require 'uniword/streaming_parser'

parser = Uniword::StreamingParser.new

# Set limits to parse only what you need
parser.set_limits(paragraphs: 100, tables: 10)

# Parse with streaming (low memory usage)
document = parser.parse_streaming(zip_content)
```

Benefits:
- Memory usage remains constant regardless of document size
- Can process documents > 100 MB
- Suitable for batch processing

### 3. Image Optimization

#### Lazy Image Loading

Images are not loaded into memory until accessed:

```ruby
# Image metadata is available immediately
image.width_in_pixels  # No data load required
image.height_in_pixels # No data load required

# Data is loaded only when needed
binary_data = image.image_data # Loaded here

# Clear data to free memory when done
image.clear_image_data
```

#### Image Caching

Once loaded, image data is cached:

```ruby
image.image_data # Loads from disk
image.image_data # Returns cached data
image.image_data_loaded? # => true
```

### 4. Serialization Performance

#### Efficient HTML Generation

HTML serialization uses array concatenation:

```ruby
parts = ['<p class="MsoNormal">']
parts.concat(paragraph.runs.map { |run| build_run_html(run) })
parts << '</p>'
parts.join
```

This approach:
- Reduces string allocations by ~50%
- Improves performance for documents with many runs
- Scales linearly with document size

## Performance Testing

### Running Benchmarks

Basic performance tests run automatically:

```bash
bundle exec rspec spec/performance/docx_performance_spec.rb
```

For comprehensive benchmarks:

```bash
PROFILE=true bundle exec rspec spec/performance/benchmark_suite_spec.rb
```

For memory profiling:

```bash
PROFILE=true bundle exec rspec spec/performance/memory_spec.rb
```

### Performance Gems

The following gems are available for performance analysis:

- `benchmark-ips`: Iterations per second benchmarking
- `benchmark-memory`: Memory allocation tracking
- `get_process_mem`: Process memory monitoring
- `ruby-prof`: Detailed profiling

Example profiling:

```ruby
require 'ruby-prof'

RubyProf.start
# ... your code ...
result = RubyProf.stop

# Print flat profile
printer = RubyProf::FlatPrinter.new(result)
printer.print(STDOUT)
```

## Best Practices

### For Large Documents

1. **Use Streaming Parser**: For documents > 10 MB
2. **Set Limits**: Parse only what you need
3. **Clear Caches**: Free memory when done processing

```ruby
parser = Uniword::StreamingParser.new
parser.set_limits(paragraphs: 1000) # Limit parsing
doc = parser.parse_streaming(content)

# Process document
process(doc)

# Clear caches to free memory
doc.clear_element_cache
```

### For Many Documents

1. **Batch Processing**: Process in batches
2. **GC Management**: Force garbage collection between batches
3. **Resource Cleanup**: Close files, clear caches

```ruby
files.each_slice(10) do |batch|
  batch.each do |file|
    doc = Uniword::DocumentFactory.from_file(file)
    process(doc)
    doc = nil
  end
  GC.start # Clean up between batches
end
```

### For Memory-Constrained Environments

1. **Use Metadata Only**: Get document info without full parse
2. **Selective Parsing**: Parse only specific sections
3. **Clear Image Data**: Don't keep images in memory

```ruby
# Get metadata without full parse
parser = Uniword::StreamingParser.new
metadata = parser.parse_metadata_only(zip_content)
# => { paragraph_count: 500, table_count: 20, has_images: true }

# Parse selectively
parser.set_limits(paragraphs: 50)
doc = parser.parse_streaming(content)
```

## Performance Monitoring

### Key Metrics to Track

1. **Parse Time**: Time to read and parse DOCX
2. **Write Time**: Time to generate and write DOCX
3. **Memory Usage**: Peak memory during operations
4. **Object Allocation**: Number of objects created

### Example Monitoring

```ruby
require 'benchmark'
require 'get_process_mem'

mem = GetProcessMem.new
GC.start
before_mb = mem.mb

time = Benchmark.realtime do
  doc = Uniword::DocumentFactory.from_file('large.docx')
  doc.save('output.docx')
end

after_mb = mem.mb
increase = after_mb - before_mb

puts "Time: #{time.round(2)}s"
puts "Memory: #{increase.round(1)}MB"
```

## Scaling Characteristics

Uniword scales linearly with document size for most operations:

- **Parsing**: O(n) where n = number of elements
- **Serialization**: O(n) where n = number of elements
- **Memory**: O(n) where n = number of elements (with lazy loading)

With streaming parser:
- **Memory**: O(1) - constant regardless of document size

## Troubleshooting Performance Issues

### Slow Parsing

**Symptoms**: Parsing takes > 1s per 100 paragraphs

**Solutions**:
1. Check for very large images in document
2. Use streaming parser for large files
3. Enable lazy loading for images
4. Check disk I/O performance

### High Memory Usage

**Symptoms**: Memory usage > 100MB for medium documents

**Solutions**:
1. Enable lazy loading
2. Clear caches after processing
3. Use streaming parser
4. Process in batches with GC

### Slow Serialization

**Symptoms**: Writing takes > 1s per 100 paragraphs

**Solutions**:
1. Check for complex table structures
2. Optimize property objects
3. Reduce unnecessary property assignments
4. Use batch operations

## Future Optimizations

Planned improvements:

- [ ] Parallel parsing for multi-core systems
- [ ] Incremental serialization
- [ ] Advanced caching strategies
- [ ] Memory-mapped file support for very large documents
- [ ] JIT optimization hints for Ruby 3.x

## Benchmark Results

Example results on MacBook Pro M1 (2021):

```
Document Size: 100 paragraphs, 10 tables
- Parse Time: 0.42s
- Write Time: 0.38s
- Memory Usage: 18.2 MB

Document Size: 500 paragraphs, 50 tables
- Parse Time: 1.87s
- Write Time: 1.65s
- Memory Usage: 67.4 MB

Document Size: 1000 paragraphs (streaming)
- Parse Time: 2.14s
- Write Time: N/A
- Memory Usage: 12.8 MB (constant)
```

## Contributing

When adding new features, please:

1. Add performance tests for new functionality
2. Ensure no performance regressions
3. Document performance characteristics
4. Use lazy loading where appropriate
5. Follow string optimization patterns

Run benchmarks before and after changes:

```bash
PROFILE=true bundle exec rspec spec/performance/