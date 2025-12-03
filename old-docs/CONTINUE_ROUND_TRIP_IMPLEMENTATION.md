# Continue Round-Trip Implementation - Schema-Driven Approach

**Created**: November 27, 2024 (REVISED)
**Context**: v1.1.0 complete, implementing 100% OOXML modeling
**Approach**: Schema-driven model generation - NO raw XML preservation
**Main Plan**: See `ROUND_TRIP_PERFECT_FIDELITY_PLAN.md` for full details

---

## Core Principle: Model Everything Properly

**CRITICAL**: We must model ALL OOXML elements using lutaml-model classes.
- NO raw XML storage
- NO "unknown element" preservation
- 100% type-safe Ruby objects
- Complete ISO 29500 compliance

**Strategy**: Schema-driven development
1. **Define schemas** - YAML files describing all OOXML elements
2. **Generate models** - Automated lutaml-model class generation
3. **Validate thoroughly** - Type safety and round-trip tests
4. **Document completely** - Every element documented

---

## Architecture Overview

### Three-Layer Architecture

```
┌─────────────────────────────────────┐
│   Application Layer (Uniword API)  │
│   - High-level document operations  │
│   - User-friendly methods           │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│  Model Layer (Generated Classes)    │
│  - lutaml-model serializable        │
│  - 100% OOXML coverage             │
│  - Type-safe attributes             │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│  Schema Layer (YAML Definitions)    │
│  - All namespaces defined           │
│  - All elements enumerated          │
│  - Complete specifications          │
└─────────────────────────────────────┘
```

### Directory Structure

```
uniword/
├── config/
│   └── ooxml/
│       └── schemas/
│           ├── wordprocessingml.yml      # w: namespace (200+ elements)
│           ├── drawingml_main.yml        # a: namespace (150+ elements)
│           ├── drawingml_wordprocessing.yml  # wp: namespace (40+ elements)
│           ├── math.yml                  # m: namespace (80+ elements)
│           ├── vml.yml                   # v: namespace (100+ elements)
│           ├── relationships.yml         # Relationship types
│           └── ... (all 30+ namespaces)
│
├── lib/
│   ├── uniword/
│   │   ├── generated/                    # Auto-generated models
│   │   │   ├── wordprocessingml/        # w: namespace classes
│   │   │   ├── drawingml/               # a:, wp: classes
│   │   │   ├── math/                    # m: namespace classes
│   │   │   └── ... (all namespaces)
│   │   │
│   │   ├── schema/                      # Schema system
│   │   │   ├── loader.rb               # Load YAML schemas
│   │   │   ├── validator.rb            # Validate against ISO 29500
│   │   │   └── definition.rb           # Schema definition classes
│   │   │
│   │   ├── generators/                  # Code generators
│   │   │   ├── model_generator.rb      # Generate lutaml-model classes
│   │   │   ├── namespace_generator.rb  # Generate namespace classes
│   │   │   └── test_generator.rb       # Generate test files
│   │   │
│   │   └── ... (handwritten core classes)
│   │
│   └── uniword.rb
│
└── spec/
    ├── generated/                       # Auto-generated tests
    └── integration/                     # Round-trip tests
```

---

## Phase 1.1: Schema System Foundation

**Time**: 2 days
**Files**: 15-20 new files
**Goal**: Infrastructure for schema-driven development

### Step 1: Schema Definition Format

**File**: `config/ooxml/schemas/wordprocessingml.yml`

```yaml
---
# WordProcessingML (w:) namespace - ISO 29500-1:2016 Section 17
namespace:
  uri: 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
  prefix: 'w'
  iso_section: '17'
  description: 'Main Word document elements'

# Element definitions (all 200+ elements must be listed)
elements:
  # Root document element
  document:
    class_name: Document
    description: 'Root element of word/document.xml'
    iso_reference: '17.2.3'
    required: true
    attributes:
      - name: conformance
        type: string
        xml_name: conformance
        xml_type: attribute
        description: 'Conformance class (transitional or strict)'
    children:
      - name: body
        type: Body
        xml_name: body
        required: true
        description: 'Document body content'
  
  # Body element
  body:
    class_name: Body
    description: 'Container for document content'
    iso_reference: '17.2.2'
    children:
      - name: elements
        type: BodyElement
        xml_name: '*'
        collection: true
        polymorphic: true
        allowed_types:
          - Paragraph
          - Table
          - SectionProperties
          - CustomXml
          - StructuredDocumentTag
          - ... (all allowed child types)
  
  # Paragraph element
  p:
    class_name: Paragraph
    description: 'Paragraph'
    iso_reference: '17.3.1.22'
    children:
      - name: properties
        type: ParagraphProperties
        xml_name: pPr
        required: false
      - name: elements
        type: ParagraphContent
        xml_name: '*'
        collection: true
        polymorphic: true
        allowed_types:
          - Run
          - Hyperlink
          - BookmarkStart
          - BookmarkEnd
          - CommentRangeStart
          - CommentRangeEnd
          - ... (all allowed types)
  
  # Run element
  r:
    class_name: Run
    description: 'Text run'
    iso_reference: '17.3.2.25'
    children:
      - name: properties
        type: RunProperties
        xml_name: rPr
      - name: content
        type: RunContent
        xml_name: '*'
        collection: true
        polymorphic: true
        allowed_types:
          - Text
          - Tab
          - Break
          - Drawing
          - Symbol
          - ... (all allowed types)
  
  # ... ALL 200+ elements enumerated with complete specifications
  # This is the foundation for 100% coverage
```

**Key Principles**:
- Every single element documented
- ISO 29500 references for all
- Complete type information
- Validation rules included
- No elements omitted

### Step 2: Schema Loader

**File**: `lib/uniword/schema/loader.rb`

```ruby
# frozen_string_literal: true

require 'yaml'

module Uniword
  module Schema
    # Loads and validates OOXML schema definitions from YAML files
    class Loader
      class << self
        # Load all schemas from config/ooxml/schemas/
        def load_all
          schema_dir = File.join(__dir__, '../../../config/ooxml/schemas')
          schemas = {}
          
          Dir.glob("#{schema_dir}/*.yml").each do |file|
            namespace_name = File.basename(file, '.yml')
            schemas[namespace_name] = load_schema(file)
          end
          
          validate_completeness!(schemas)
          schemas
        end
        
        # Load single schema file
        def load_schema(file_path)
          raw = YAML.load_file(file_path)
          Definition.new(raw)
        end
        
        private
        
        # Ensure all required elements are present
        def validate_completeness!(schemas)
          # Check that all ISO 29500 required elements are covered
          required_elements = ISO29500_REQUIRED_ELEMENTS
          
          schemas.each do |name, schema|
            missing = required_elements[name] - schema.element_names
            raise IncompletSchemaError, "Missing elements in #{name}: #{missing}" if missing.any?
          end
        end
      end
    end
  end
end
```

### Step 3: Schema Definition Class

**File**: `lib/uniword/schema/definition.rb`

```ruby
module Uniword
  module Schema
    # Represents a complete schema definition for a namespace
    class Definition
      attr_reader :namespace, :elements
      
      def initialize(raw_yaml)
        @namespace = Namespace.new(raw_yaml['namespace'])
        @elements = parse_elements(raw_yaml['elements'])
        validate!
      end
      
      def element_names
        @elements.keys
      end
      
      def element(name)
        @elements[name] or raise UnknownElementError, "No element '#{name}' in #{namespace.prefix}: namespace"
      end
      
      private
      
      def parse_elements(raw_elements)
        raw_elements.transform_values do |definition|
          ElementDefinition.new(definition)
        end
      end
      
      def validate!
        # Ensure schema is complete and consistent
        @elements.each do |name, element|
          element.validate!(self)
        end
      end
    end
    
    # Represents a single element definition
    class ElementDefinition
      attr_reader :class_name, :description, :iso_reference, 
                  :attributes, :children, :required
      
      def initialize(definition)
        @class_name = definition['class_name']
        @description = definition['description']
        @iso_reference = definition['iso_reference']
        @required = definition['required'] || false
        @attributes = parse_attributes(definition['attributes'] || [])
        @children = parse_children(definition['children'] || [])
        
        raise InvalidDefinitionError, "Missing class_name" unless @class_name
      end
      
      def validate!(schema)
        # Validate that all referenced types exist
        children.each do |child|
          child.validate_types!(schema)
        end
      end
      
      private
      
      def parse_attributes(raw_attrs)
        raw_attrs.map { |attr| AttributeDefinition.new(attr) }
      end
      
      def parse_children(raw_children)
        raw_children.map { |child| ChildDefinition.new(child) }
      end
    end
  end
end
```

### Step 4: Model Generator

**File**: `lib/uniword/generators/model_generator.rb`

```ruby
module Uniword
  module Generators
    # Generates lutaml-model classes from schema definitions
    class ModelGenerator
      def initialize(schema)
        @schema = schema
      end
      
      def generate_all
        @schema.elements.each do |tag_name, element_def|
          generate_model_class(tag_name, element_def)
        end
      end
      
      def generate_model_class(tag_name, element_def)
        namespace_dir = namespace_directory(@schema.namespace)
        class_file = File.join(namespace_dir, "#{underscore(element_def.class_name)}.rb")
        
        code = build_class_code(tag_name, element_def)
        File.write(class_file, code)
        
        puts "Generated: #{class_file}"
      end
      
      private
      
      def build_class_code(tag_name, element_def)
        <<~RUBY
          # frozen_string_literal: true
          # AUTO-GENERATED from schema - DO NOT EDIT
          # ISO 29500 Reference: #{element_def.iso_reference}
          
          module Uniword
            module Generated
              module #{namespace_module(@schema.namespace)}
                # #{element_def.description}
                class #{element_def.class_name} < Lutaml::Model::Serializable
                  #{generate_attributes(element_def)}
                  
                  xml do
                    root '#{tag_name}'
                    namespace #{namespace_constant(@schema.namespace)}
                    #{generate_xml_mappings(element_def)}
                  end
                end
              end
            end
          end
        RUBY
      end
      
      def generate_attributes(element_def)
        lines = []
        
        # XML attributes
        element_def.attributes.each do |attr|
          lines << "attribute :#{attr.name}, :#{attr.type}"
        end
        
        # Child elements
        element_def.children.each do |child|
          if child.collection?
            lines << "attribute :#{child.name}, #{child.type}, collection: true"
          else
            lines << "attribute :#{child.name}, #{child.type}"
          end
        end
        
        lines.join("\n    ")
      end
      
      def generate_xml_mappings(element_def)
        lines = []
        
        element_def.attributes.each do |attr|
          lines << "map_attribute '#{attr.xml_name}', to: :#{attr.name}"
        end
        
        element_def.children.each do |child|
          if child.polymorphic?
            # Polymorphic children need special handling
            lines << "# Polymorphic: #{child.allowed_types.join(', ')}"
            lines << "map_element '*', to: :#{child.name}"
          else
            lines << "map_element '#{child.xml_name}', to: :#{child.name}"
          end
        end
        
        lines.map { |l| "    #{l}" }.join("\n")
      end
    end
  end
end
```

### Step 5: Generator Tasks

**File**: `lib/tasks/generate_models.rake`

```ruby
namespace :uniword do
  namespace :generate do
    desc 'Generate all lutaml-model classes from schemas'
    task :models do
      require_relative '../uniword/schema/loader'
      require_relative '../uniword/generators/model_generator'
      
      # Load all schemas
      schemas = Uniword::Schema::Loader.load_all
      
      # Generate models for each namespace
      schemas.each do |namespace_name, schema|
        puts "Generating models for #{namespace_name}..."
        generator = Uniword::Generators::ModelGenerator.new(schema)
        generator.generate_all
      end
      
      puts "\nModel generation complete!"
      puts "Generated classes in lib/uniword/generated/"
    end
    
    desc 'Validate schemas against ISO 29500'
    task :validate do
      require_relative '../uniword/schema/loader'
      require_relative '../uniword/schema/validator'
      
      schemas = Uniword::Schema::Loader.load_all
      validator = Uniword::Schema::Validator.new
      
      schemas.each do |name, schema|
        result = validator.validate(schema)
        if result.valid?
          puts "✓ #{name}: Valid"
        else
          puts "✗ #{name}: #{result.errors.count} errors"
          result.errors.each { |e| puts "  - #{e}" }
        end
      end
    end
  end
end
```

---

## Success Criteria for Phase 1.1

**Schema System**:
- ✅ YAML schema format defined and documented
- ✅ Schema loader loads all namespace definitions
- ✅ Schema validator checks completeness
- ✅ All 30+ namespaces have schema files

**Model Generation**:
- ✅ ModelGenerator creates valid lutaml-model classes
- ✅ Generated classes pass RuboCop
- ✅ All generated classes have proper namespacing
- ✅ XML mappings are correct

**Validation**:
- ✅ ISO 29500 compliance checking works
- ✅ Missing elements are detected
- ✅ Type references are validated

---

## Next Steps After Phase 1.1

1. **Phase 1.2**: Complete all namespace schemas (WordProcessingML first)
2. **Phase 1.3**: Generate all model classes
3. **Phase 2.1**: Integrate generated models with existing code
4. **Phase 2.2**: Write round-trip tests for each namespace

---

## Key Architectural Principles

1. **Schema-Driven**: Everything derives from YAML schemas
2. **Generated Code**: Models are auto-generated, not hand-written
3. **Type-Safe**: Complete type safety via lutaml-model
4. **ISO Compliant**: Every element references ISO 29500
5. **Maintainable**: Change schema → regenerate → done
6. **Testable**: Each namespace fully tested
7. **Documented**: Complete API docs auto-generated

---

## Development Workflow

```bash
# 1. Edit schema
vim config/ooxml/schemas/wordprocessingml.yml

# 2. Validate schema
rake uniword:generate:validate

# 3. Generate models
rake uniword:generate:models

# 4. Run tests
bundle exec rspec spec/generated/

# 5. Commit both schema and generated code
git add config/ooxml/schemas/ lib/uniword/generated/
git commit -m "feat: complete WordProcessingML schema"
```

---

## Timeline

**Phase 1.1** (Schema System): 2 days
**Phase 1.2** (All Schemas): 5-7 days (collaborative - split across team)
**Phase 1.3** (Model Generation): 1 day
**Phase 2** (Integration): 3-4 days
**Phase 3** (Testing): 2-3 days

**Total**: 13-17 days

---

## Resources

- ISO/IEC 29500-1:2016 (WordProcessingML)
- ISO/IEC 29500-2:2016 (DrawingML)
- ISO/IEC 29500-3:2016 (SpreadsheetML)
- ISO/IEC 29500-4:2016 (Shared Types)
- ECMA-376 5th Edition (online reference)

---

## Conclusion

This schema-driven approach ensures:
- 100% OOXML coverage
- Zero raw XML usage
- Complete type safety
- Perfect round-trip fidelity
- Maintainable codebase
- Scalable architecture

Start with Phase 1.1 to build the foundation, then systematically complete all namespace schemas.