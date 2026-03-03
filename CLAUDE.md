# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Uniword is a Ruby library for reading, writing, and manipulating OOXML (Office Open XML) documents, specifically Microsoft Word (.docx) files. It provides a model-driven architecture where all XML structures are represented as Ruby objects.

## Development Commands

```bash
# Run all tests
bundle exec rspec

# Run a single test file
bundle exec rspec spec/uniword/wordprocessingml/document_spec.rb

# Run a specific test by line number
bundle exec rspec spec/uniword/wordprocessingml/document_spec.rb:42

# Run linter with auto-fix
bundle exec rubocop -A --auto-gen-config

# Start interactive console with uniword loaded
bundle exec rake console

# Generate documentation
bundle exec yard doc
```

## Architecture

Uniword uses a 4-layer model-driven architecture:

1. **Document Model Layer**: Core OOXML element classes representing 760 elements across 22 namespaces
2. **Properties Layer**: Wrapper classes for common formatting operations
3. **Serialization Layer**: XML/JSON/YAML serialization via lutaml-model
4. **Format Handler Layer**: DOCX package handling via rubyzip

### Key Namespaces

- **WordProcessingML (w:)**: Main document content - paragraphs, runs, tables
- **DrawingML (a:)**: Images, shapes, charts
- **Math (m:)**: Mathematical equations (OMML)
- **VML (v:)**: Legacy vector graphics
- **Relationships (r:)**: Document relationships and references

### Model Inheritance

All serializable models inherit from `Lutaml::Model::Serializable` and use the lutaml-model DSL for XML mapping.

## Critical Pattern: Attribute Declaration Order

**Pattern 0 - MANDATORY**: In all lutaml-model classes, attributes MUST be declared BEFORE the `xml` block:

```ruby
# ✅ CORRECT - Attributes FIRST
class Bold < Lutaml::Model::Serializable
  attribute :value, :boolean, default: -> { true }

  xml do
    element 'b'
    namespace Uniword::Ooxml::Namespaces::WordProcessingML
    map_attribute 'val', to: :value, render_nil: false, render_default: false
  end
end

# ❌ WRONG - Will silently produce empty XML output
class Bold < Lutaml::Model::Serializable
  xml do
    element 'b'
    # ... mappings
  end

  attribute :value, :boolean  # TOO LATE - ignored!
end
```

Violating this pattern causes silent serialization failures where XML output is empty. This applies to ALL classes using lutaml-model.

## Local Development Dependencies

This project uses local paths for bleeding-edge development of related gems:

```ruby
# Gemfile
gem 'lutaml-model', path: '/Users/mulgogi/src/lutaml/lutaml-model'
gem 'plurimath', path: '/Users/mulgogi/src/plurimath/plurimath'
gem 'canon', path: '/Users/mulgogi/src/lutaml/canon'
```

Changes to these local gems will affect this project. The `lutaml-model` README is at `$HOME/src/lutaml/lutaml-model/README.adoc`.

## Autoload Strategy

The codebase uses a 95% autoload / 5% require_relative strategy:

- Most classes use `autoload` for lazy loading
- `require_relative` is used when:
  - Constants from a file are needed at load time
  - Inheritance chains require parent class availability
  - Utility modules are referenced in class definitions

## Code Style

- Use 2 spaces for indentation, no tabs
- Max line length: 80 characters
- Always use `require_relative` for internal file loading
- Never use `Struct` or `OpenStruct` - use proper model classes
- Each class/module requires its own RSpec test file
- Run Rubocop before committing

## File Organization

```
lib/uniword/
├── ooxml/           # OOXML schema definitions (YAML) and generated classes
├── wordprocessingml/ # Document, Body, Paragraph, Run, Table, etc.
├── drawingml/       # DrawingML elements
├── math/            # Math (OMML) elements
├── vml/             # VML graphics elements
├── properties/      # Property wrapper classes for common operations
└── cli.rb           # Thor-based CLI interface
```

## Testing

- Tests use RSpec without mocks or stubs
- Use `let` for shared variables
- Test fixtures belong in `spec/fixtures/`
- Each test should focus on a single behavior
- Follow MECE (Mutually Exclusive, Collectively Exhaustive) principles
