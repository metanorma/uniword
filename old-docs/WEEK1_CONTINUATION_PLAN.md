# Week 1 Round-Trip Fix: Type-Level Namespace Refactoring Plan

## Date
2025-11-15

## Current Status

**Achieved**: Lutaml-model foundation for docProps serialization
**Current Test Results**: 1/13 Canon tests passing (webSettings.xml only)
**Blocking Issue**: Using incorrect namespace pattern

### What's Working ✅
- CoreProperties and AppProperties use Lutaml::Model::Serializable
- XmlNamespace classes defined for all needed namespaces
- Serialization produces multi-namespace XML
- Deserialization parses multi-namespace XML
- 22/22 unit tests passing for isolated property objects
- No Hash-based metadata (clean architecture)

### What's Broken ❌
- **Wrong Pattern**: Using `namespace:` and `prefix:` parameters in `map_element`
- **Correct Pattern**: Should use `Type::Value` classes with `namespace` declarations
- Missing `xsi:type="dcterms:W3CDTF"` attributes on timestamps
- Empty elements not rendering as `<dc:title/>` (rendering as `xsi:nil` instead)
- Element ordering issues in app.xml

## Root Cause Analysis

Current implementation (INCORRECT):
```ruby
map_element 'title', to: :title,
            namespace: 'http://purl.org/dc/elements/1.1/',
            prefix: 'dc'
```

**Problem**: Namespace hardcoded in mapping, not coming from Type definition.

Correct implementation (per TODO.value-namespace.md):
```ruby
class DcTitleType < Lutaml::Model::Type::String
  namespace Namespaces::DublinCore  # Type declares its namespace
end

attribute :title, DcTitleType  # Type provides namespace

map_element 'title', to: :title  # NO namespace param - inherited from Type!
```

## Refactoring Plan

### Phase 1: Create Type Classes (30 minutes)

#### File: lib/uniword/ooxml/types.rb
```ruby
# frozen_string_literal: true

module Uniword
  module Ooxml
    module Types
      # Autoload all type classes
    end
  end
end
```

#### Dublin Core Types (3 files)

**lib/uniword/ooxml/types/dc_title_type.rb**:
```ruby
module Uniword
  module Ooxml
    module Types
      class DcTitleType < Lutaml::Model::Type::String
        namespace Namespaces::DublinCore
      end
    end
  end
end
```

**lib/uniword/ooxml/types/dc_subject_type.rb**:
```ruby
module Uniword
  module Ooxml
    module Types
      class DcSubjectType < Lutaml::Model::Type::String
        namespace Namespaces::DublinCore
      end
    end
  end
end
```

**lib/uniword/ooxml/types/dc_creator_type.rb**:
```ruby
module Uniword
  module Ooxml
    module Types
      class DcCreatorType < Lutaml::Model::Type::String
        namespace Namespaces::DublinCore
      end
    end
  end
end
```

#### Core Properties Types (4 files)

**lib/uniword/ooxml/types/cp_keywords_type.rb**:
```ruby
module Uniword
  module Ooxml
    module Types
      class CpKeywordsType < Lutaml::Model::Type::String
        namespace Namespaces::CoreProperties
      end
    end
  end
end
```

**lib/uniword/ooxml/types/cp_description_type.rb**:
```ruby
module Uniword
  module Ooxml
    module Types
      class CpDescriptionType < Lutaml::Model::Type::String
        namespace Namespaces::CoreProperties
      end
    end
  end
end
```

**lib/uniword/ooxml/types/cp_last_modified_by_type.rb**:
```ruby
module Uniword
  module Ooxml
    module Types
      class CpLastModifiedByType < Lutaml::Model::Type::String
        namespace Namespaces::CoreProperties
      end
    end
  end
end
```

**lib/uniword/ooxml/types/cp_revision_type.rb**:
```ruby
module Uniword
  module Ooxml
    module Types
      class CpRevisionType < Lutaml::Model::Type::String
        namespace Namespaces::CoreProperties
      end
    end
  end
end
```

#### Timestamp Type (1 file - complex)

**lib/uniword/ooxml/types/dcterms_w3cdtf_type.rb**:
```ruby
module Uniword
  module Ooxml
    module Types
      # Represents dcterms timestamps with xsi:type="dcterms:W3CDTF"
      class DctermsW3CDTFType < Lutaml::Model::Serializable
        namespace Namespaces::DublinCoreTerms

        attribute :value, :string
        attribute :xsi_type, :string, default: -> { 'dcterms:W3CDTF' }

        xml do
          # Type-only model (no element name)
          map_attribute 'type', to: :xsi_type,
                        namespace: 'http://www.w3.org/2001/XMLSchema-instance',
                        prefix: 'xsi'
          map_content to: :value
        end

        # Initialize from string
        def self.cast(value)
          return value if value.is_a?(self)
          new(value: value.to_s)
        end
      end
    end
  end
end
```

### Phase 2: Refactor CoreProperties (15 minutes)

**lib/uniword/ooxml/core_properties.rb**:
```ruby
require_relative 'namespaces'
require_relative 'types/dc_title_type'
require_relative 'types/dc_subject_type'
require_relative 'types/dc_creator_type'
require_relative 'types/cp_keywords_type'
require_relative 'types/cp_description_type'
require_relative 'types/cp_last_modified_by_type'
require_relative 'types/cp_revision_type'
require_relative 'types/dcterms_w3cdtf_type'

module Uniword
  module Ooxml
    class CoreProperties < Lutaml::Model::Serializable
      namespace Namespaces::CoreProperties

      # Use Type classes - namespaces come from Type definitions
      attribute :title, Types::DcTitleType
      attribute :subject, Types::DcSubjectType
      attribute :creator, Types::DcCreatorType
      attribute :keywords, Types::CpKeywordsType
      attribute :description, Types::CpDescriptionType
      attribute :last_modified_by, Types::CpLastModifiedByType
      attribute :revision, Types::CpRevisionType
      attribute :created, Types::DctermsW3CDTFType
      attribute :modified, Types::DctermsW3CDTFType

      xml do
        element 'coreProperties'

        # NO namespace parameters - Types provide namespaces automatically!
        map_element 'title', to: :title, render_nil: :as_blank, render_empty: :as_blank
        map_element 'subject', to: :subject, render_nil: :as_blank, render_empty: :as_blank
        map_element 'creator', to: :creator, render_nil: :as_blank, render_empty: :as_blank
        map_element 'keywords', to: :keywords, render_nil: :as_blank, render_empty: :as_blank
        map_element 'description', to: :description, render_nil: :as_blank, render_empty: :as_blank
        map_element 'lastModifiedBy', to: :last_modified_by
        map_element 'revision', to: :revision
        map_element 'created', to: :created
        map_element 'modified', to: :modified
      end

      def initialize(attributes = {})
        super
        @created ||= Types::DctermsW3CDTFType.new(value: Time.now.utc.iso8601)
        @modified ||= Types::DctermsW3CDTFType.new(value: Time.now.utc.iso8601)
      end
    end
  end
end
```

### Phase 3: Test and Verify (15 minutes)

Run tests:
```bash
# Unit tests should still pass
bundle exec rspec spec/uniword/ooxml/core_properties_spec.rb
bundle exec rspec spec/uniword/ooxml/app_properties_spec.rb

# Round-trip tests
bundle exec rspec spec/uniword/ooxml/complete_roundtrip_spec.rb
```

Verify:
1. `<dc:title/>` empty elements render correctly
2. `<dcterms:created xsi:type="dcterms:W3CDTF">` attributes present
3. docProps/core.xml Canon test passes
4. docProps/app.xml Canon test passes

### Phase 4: Fix Remaining Issues

If tests still fail:

**core.xml issues**:
- Adjust `render_nil` and `render_empty` settings
- Verify xsi:type attribute serialization

**app.xml issues**:
- Check element ordering (may need explicit ordering in xml block)
- Verify Company empty element renders as `<Company/>`

## Implementation Checklist

- [ ] Create lib/uniword/ooxml/types/ directory
- [ ] Create 8 Type::Value classes (Dublin Core + Core Properties)
- [ ] Create DctermsW3CDTFType complex type
- [ ] Refactor CoreProperties to use Type classes
- [ ] Remove namespace/prefix from map_element calls
- [ ] Update tests if Type changes affect assertions
- [ ] Run unit tests - verify 22/22 still pass
- [ ] Run complete_roundtrip_spec.rb
- [ ] Verify docProps/core.xml passes Canon test
- [ ] Verify docProps/app.xml passes Canon test
- [ ] Document any remaining issues for Week 2

## Success Criteria

✅ docProps/core.xml: Canon equivalent after round-trip
✅ docProps/app.xml: Canon equivalent after round-trip
✅ All unit tests passing (22/22)
✅ Type-level namespace pattern established
✅ Foundation ready for Week 2 (other OOXML files)

## Estimated Time

**Total: 60-90 minutes**
- Create Type classes: 30 min
- Refactor CoreProperties: 15 min
- Refactor AppProperties (if needed): 15 min
- Debug and fix issues: 20-40 min
- Verification: 10 min

---

## Session Continuation Prompt

**Refactor CoreProperties to use Type-level namespaces per TODO.value-namespace.md pattern. Current implementation uses namespace in map_element (wrong). Should use Type::Value classes with namespace declarations (correct). Goal: achieve docProps/core.xml and docProps/app.xml round-trip with 100% Canon equivalence.**

**Start by**:
1. Read WEEK1_CONTINUATION_PLAN.md
2. Read /Users/mulgogi/src/lutaml/lutaml-model/TODO.value-namespace.md lines 106-183 (the correct pattern)
3. Create Type classes in lib/uniword/ooxml/types/ directory
4. Refactor CoreProperties to use Type classes
5. Run tests to verify Canon equivalence

**Current files**:
- lib/uniword/ooxml/core_properties.rb (needs refactoring)
- lib/uniword/ooxml/namespaces.rb (correct XmlNamespace classes)
- spec/uniword/ooxml/complete_roundtrip_spec.rb (comprehensive round-trip test)