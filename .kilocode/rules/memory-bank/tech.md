// ... existing code ...
# Uniword: Technologies and Development Setup

## Technology Stack

### Core Technologies

**Ruby**: >= 2.7.0
- Object-oriented programming language
- Chosen for expressiveness and metaprogramming capabilities
- Test-driven development with RSpec

**Lutaml-Model**: ~> 0.7
- XML serialization and deserialization framework
- Native namespace support (v0.7+)
- Declarative model definitions
- Provides XML/YAML/JSON adapters

### 🚨 CRITICAL: Lutaml-Model Attribute Declaration Pattern

**THE MOST IMPORTANT RULE**: Attributes MUST be declared BEFORE xml mappings!

```ruby
# ✅ CORRECT - Attributes FIRST
class MyClass < Lutaml::Model::Serializable
  attribute :my_attr, MyType
  
  xml do
    map_element 'elem', to: :my_attr
  end
end

# ❌ WRONG - Will NOT serialize
class MyClass < Lutaml::Model::Serializable
  xml do
    map_element 'elem', to: :my_attr
  end
  attribute :my_attr, MyType  # Too late!
end
```

**Why This Matters**:
- Lutaml-model builds its internal schema by reading attribute declarations
- If attributes are declared after xml block, framework doesn't know they exist
- Result: Serialization produces empty XML, deserialization fails silently
- This was the root cause of complete document serialization failure in v1.1.0 development

**Additional Rules**:
- Use `mixed_content` for elements with nested content
- Only ONE namespace declaration per element level
- Use `render_default: true` for optional elements that must always appear
- In `initialize`, use `||=` not `=` to preserve lutaml-model parsed values

**Nokogiri**: ~> 1.15
- XML parsing and generation
- LibXML2 bindings for performance
- Used for manual XML building in serializers

**RubyZip**: ~> 2.3
- ZIP file creation and extraction
- Essential for DOCX format (ZIP packages)
- Handles compression and decompression

**Thor**: ~> 1.3
- CLI framework
- Command-line tools and user interface
- Option parsing and validation

**Mail**: ~> 2.8
- MIME message handling
- Required for MHTML format support
- Multipart message parsing

### Development Dependencies

**RSpec**: Testing framework
- ~2100+ test examples
- Unit, integration, and round-trip tests
- Custom matchers for XML comparison

**Canon**: Semantic XML comparison
- W3C XML C14N (Canonicalization)
- Ignores whitespace and attribute order
- Perfect for round-trip validation

**Plurimath**: Math equation support
- MathML and AsciiMath conversion
- Office Math Markup Language (OMML)
- Critical for ISO documents

**Rubocop**: Code quality
- Ruby style guide enforcement
- Automatic fixing with `-A`
- Custom configuration in `.rubocop.yml`

## Development Setup

### Local Development Paths

For bleeding-edge features, Uniword uses local gem paths:

```ruby
# Gemfile
gem 'lutaml-model', path: '/Users/mulgogi/src/lutaml/lutaml-model'
gem 'plurimath', path: '/Users/mulgogi/src/plurimath/plurimath'
gem 'canon', path: '/Users/mulgogi/src/lutaml/canon'
```

**Why Local Paths:**
- Developing namespace features in parallel
- Quick iteration on XML serialization
- Testing unreleased features

### Installation

```bash
# Clone repository
git clone https://github.com/metanorma/uniword.git
cd uniword

# Install dependencies
bundle install

# Run tests
bundle exec rspec

# Run linter
bundle exec rubocop -A --auto-gen-config
```

### Project Structure

```
uniword/
├── lib/                    # Production code
│   └── uniword/           # Main library
├── spec/                  # RSpec tests
│   ├── uniword/          # Unit & integration tests
│   └── fixtures/         # Test files
├── data/                  # Bundled resources
│   ├── themes/           # Office themes (YAML)
│   └── stylesets/        # Office StyleSets (YAML)
├── bin/                   # Executables
│   └── uniword           # CLI tool
├── docs/                  # Documentation
│   ├── NAMESPACE_MIGRATION_GUIDE.md
│   └── NAMESPACE_AND_STYLESET_ARCHITECTURE.md
├── references/            # Reference files
├── examples/              # Usage examples
├── Gemfile
├── uniword.gemspec
└── README.adoc
```

## Technical Constraints

### 1. OOXML Specification Compliance

**Constraint**: Must follow ISO 29500 standard
**Current**: ~40% coverage (v1.x)
**Target**: 100% coverage (v2.0)

**Implications:**
- Namespace handling critical
- Unknown elements must be preserved
- Perfect round-trip required

### 2. Memory Management

**Constraint**: Large documents (1000+ pages) must load efficiently
**Solution**: Lazy loading and streaming

**Implementation:**
```ruby
class Document
  def paragraphs
    @cached_paragraphs ||= body.paragraphs
  end

  def clear_element_cache
    @cached_paragraphs = nil
  end
end
```

### 3. Performance Targets

- Simple doc generation: < 50ms
- Complex doc (50 pages): < 500ms
- StyleSet load+apply: < 500ms
- Theme application: < 100ms

### 4. Format Support

**DOCX (Word 2007+)**:
- ZIP package with XML files
- OOXML specification
- Primary format

**MHTML (Word 2003+)**:
- MIME multipart format
- Legacy support
- Challenges with preservation

### 5. Ruby Version Compatibility

**Minimum**: Ruby 2.7.0
**Testing**: 2.7, 3.0, 3.1, 3.2, 3.3
**Gemfile.lock**: Committed for consistency

## Tool Usage Patterns

### 1. RSpec Testing

**Pattern**: Descriptive test organization

```ruby
RSpec.describe Uniword::StyleSet do
  describe '.from_dotx' do
    it 'loads StyleSet from .dotx file' do
      styleset = Uniword::StyleSet.from_dotx('Distinctive.dotx')
      expect(styleset.name).to eq('Distinctive')
    end
  end
end
```

**Test Types:**
- Unit tests: Individual class behavior
- Integration tests: Component interaction
- Round-trip tests: Load → Save → Compare

### 2. Rubocop Configuration

**Auto-fix approach:**
```bash
bundle exec rubocop -A --auto-gen-config
```

**After auto-fix:** Run tests to ensure nothing broke

**Style Guide:** Customized via `.rubocop.yml`

### 3. Canon XML Comparison

**Semantic comparison** (ignores whitespace, attribute order):

```ruby
require 'canon/rspec_matchers'

expect(generated_xml).to be_xml_equivalent_to(original_xml)
```

**Perfect for:** Round-trip validation where formatting may differ

### 4. Git Workflow

**Commit Message Format:**
```
<type>(<scope>): <subject>

feat(styleset): add complete property parsing
fix(namespace): resolve Math namespace handling
docs(readme): update StyleSet examples
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `refactor`: Code restructuring
- `test`: Test additions
- `chore`: Build/tooling

### 5. CLI Usage

**Uniword CLI** (Thor-based):

```bash
# Convert formats
uniword convert input.docx output.doc

# Document info
uniword info document.docx --verbose

# Validate structure
uniword validate document.docx
```

## Dependencies Detail

### Production Gems

```ruby
# XML/Serialization
gem 'lutaml-model', '~> 0.7'  # Model framework
gem 'nokogiri', '~> 1.15'      # XML parsing

# File Formats
gem 'rubyzip', '~> 2.3'        # ZIP handling
gem 'mail', '~> 2.8'           # MIME/MHTML

# CLI
gem 'thor', '~> 1.3'           # Command framework
```

### Development Gems

```ruby
# Testing
gem 'rspec'                    # Test framework
gem 'canon'                    # XML comparison

# Code Quality
gem 'rubocop'                  # Style checker
gem 'yard'                     # Documentation

# Performance
gem 'benchmark-ips'            # Benchmarking
gem 'benchmark-memory'         # Memory profiling
gem 'ruby-prof'                # Profiling
```

### Gem Constraints

**No version pins in development** except for production dependencies:
```ruby
# Development gems (no version)
gem 'rake'
gem 'rspec'
gem 'rubocop'

# Production gems (versioned)
gem 'lutaml-model', '~> 0.7'
gem 'nokogiri', '~> 1.15'
```

**Reason**: Always use latest development tools

## Build and Release

### Version Management

**Current**: 1.0.0 (released)
**Next**: 1.1.0 (in development)
**Future**: 2.0.0 (schema-driven)

**Version file:** `lib/uniword/version.rb`

### Gemspec Configuration

**Essential metadata:**
```ruby
spec.name        = 'uniword'
spec.version     = Uniword::VERSION
spec.authors     = ['Ribose Inc.']
spec.license     = 'BSD-2-Clause'
spec.files       = Dir.glob(%w[lib/**/*.rb data/**/*.yml])
```

### Release Process

1. Update `CHANGELOG.md`
2. Bump version in `version.rb`
3. Run full test suite
4. Run rubocop
5. Build gem: `gem build uniword.gemspec`
6. Push to RubyGems: `gem push uniword-x.x.x.gem`
7. Tag release: `git tag vx.x.x`

## Integration Points

### Metanorma Ecosystem

Uniword is part of the Metanorma toolchain:
- **Metanorma**: Document authoring
- **Lutaml**: Modeling and serialization
- **Plurimath**: Math equations
- **Canon**: XML canonicalization

### External Libraries

**Nokogiri** (LibXML2):
- Critical dependency
- Performance bottleneck
- Memory management important

**Lutaml-Model** (Active development):
- Local development path during feature work
- Namespace support added in v0.7+
- Close collaboration on features

## Performance Profiling

### Benchmarking

```ruby
require 'benchmark/ips'

Benchmark.ips do |x|
  x.report('simple doc') do
    doc = Uniword::Document.new
    doc.add_paragraph('Hello World')
    doc.save('test.docx')
  end
end
```

### Memory Profiling

```ruby
require 'benchmark/memory'

Benchmark.memory do |x|
  x.report('load styleset') do
    Uniword::StyleSet.load('distinctive')
  end
end
```

### Profiling Tools

- `ruby-prof`: Code profiling
- `get_process_mem`: Memory tracking
- `benchmark-ips`: Performance comparison
- `benchmark-memory`: Memory comparison

## Testing Infrastructure

### Test Organization

```
spec/
├── uniword/
│   ├── *_spec.rb               # Unit tests
│   ├── *_integration_spec.rb   # Integration tests
│   └── *_roundtrip_spec.rb     # Round-trip tests
├── fixtures/                    # Test files
└── spec_helper.rb              # Configuration
```

### Test Execution

```bash
# All tests
bundle exec rspec

# Specific file
bundle exec rspec spec/uniword/document_spec.rb

# Tag-based
bundle exec rspec --tag integration

# Pattern-based
bundle exec rspec spec/uniword/*integration*
```

### Continuous Integration

**GitHub Actions** (`.github/workflows/rake.yml`):
- Run on push and PR
- Test against multiple Ruby versions
- Code coverage reporting
- Rubocop validation

## Documentation Tools

### YARD Documentation

```bash
# Generate docs
bundle exec yard doc

# View locally
bundle exec yard server
```

**Doc Comments:**
```ruby
# @param path [String] File path
# @return [Document] Loaded document
# @raise [FileNotFoundError] if file not found
def self.open(path)
  # ...
end
```

### AsciiDoc (README)

**Format**: `README.adoc`
**Why**: Better than Markdown for technical docs
- Code blocks with syntax highlighting
- Includes and cross-references
- Table support

## Future Technology Plans

### v2.0.0: Schema-Driven Architecture

**New Dependencies:**
- YAML schema definitions (no new gems)
- Generic serializer (built-in)
- Schema validator (to be implemented)

**Technology Shift:**
- From hardcoded XML → Schema-driven
- From 40% coverage → 100% OOXML
- From maintainability challenges → Easy extensions

**Timeline**: 8-10 weeks after v1.1.0 release
// ... existing code ...