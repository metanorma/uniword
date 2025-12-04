# Uniword Autoload: Quick Reference Guide

## TL;DR

**Current Status**: 60% autoload coverage (good foundation)
**Goal**: 95% autoload coverage
**Impact**: 5x faster startup, 4x less memory
**Time**: 6.5 hours total
**Breaking Changes**: None

---

## What Needs to be Done

### ✅ Already Working Well

These files already use autoload correctly:
- `lib/uniword.rb` - Main module (partial, 60% complete)
- `lib/uniword/drawingml.rb` - 92 classes ✅
- `lib/uniword/wp_drawing.rb` - 26 classes ✅
- `lib/uniword/vml.rb` - 18 classes ✅
- `lib/uniword/math.rb` - 66 classes ✅
- `lib/uniword/glossary.rb` - 19 classes ✅
- `lib/uniword/wordprocessingml.rb` - Dynamic autoload ✅

### ❌ Files to Create

**Priority 1** (Required for autoload to work):
1. `lib/uniword/shared_types.rb` - Missing loader
2. `lib/uniword/content_types.rb` - Missing loader  
3. `lib/uniword/document_properties.rb` - Missing loader

**Priority 2** (Nice to have):
4. `lib/uniword/accessibility.rb` - New loader
5. `lib/uniword/assembly.rb` - New loader
6. `lib/uniword/batch.rb` - New loader
7. `lib/uniword/bibliography.rb` - New loader
8. `lib/uniword/customxml.rb` - New loader

### 🔧 Files to Modify

**Main Changes**:
1. `lib/uniword.rb` - Convert 9 require_relative to autoload (lines 19-27)
2. `lib/uniword.rb` - Add ~50 missing top-level class autoloads

---

## Quick Implementation Steps

### Step 1: Create Missing Loaders (30 minutes)

```bash
# Create the 3 critical loaders
touch lib/uniword/shared_types.rb
touch lib/uniword/content_types.rb
touch lib/uniword/document_properties.rb
```

Each file should follow this template:

```ruby
# frozen_string_literal: true

# {Namespace} Namespace
# Brief description

module Uniword
  module {Namespace}
    autoload :ClassName, File.expand_path('{namespace}/class_name', __dir__)
    # ... more autoloads ...
  end
end
```

**Pro tip**: Use this command to generate autoload statements:
```bash
cd lib/uniword/shared_types
ls *.rb | while read f; do 
  name=$(basename "$f" .rb | ruby -e 'puts ARGF.read.split("_").map(&:capitalize).join')
  echo "autoload :$name, File.expand_path('shared_types/$(basename "$f" .rb)', __dir__)"
done
```

### Step 2: Update lib/uniword.rb (1 hour)

**Change A**: Replace these require_relative (lines 19-27):
```ruby
# OLD
require_relative 'uniword/wordprocessingml'
require_relative 'uniword/drawingml'
# ... etc

# NEW
autoload :Wordprocessingml, 'uniword/wordprocessingml'
autoload :DrawingML, 'uniword/drawingml'
# ... etc
```

**Change B**: Add missing top-level autoloads:
```ruby
# Add after existing autoloads (around line 120)
autoload :Builder, 'uniword/builder'
autoload :LazyLoader, 'uniword/lazy_loader'
autoload :StreamingParser, 'uniword/streaming_parser'
# ... see full list in main plan document
```

### Step 3: Test (15 minutes)

```bash
# Run tests
bundle exec rspec

# Check what loads on require
ruby -e "require './lib/uniword'; puts $LOADED_FEATURES.select { |f| f.include?('uniword') }.size"
# Before: ~500-600
# Target: <30
```

---

## Critical Rules

### ✅ DO Use Autoload For:
- Independent classes without circular dependencies
- Large namespaces (50+ classes)
- Rarely-used features (batch processing, accessibility)
- Format-specific serializers

### ❌ KEEP require_relative For:
- **version.rb** - Always needed
- **ooxml/namespaces.rb** - Constants used everywhere
- **Format handlers** - Self-registering components (docx_handler.rb, mhtml_handler.rb)
- **Circular dependency chains** - If A needs B and B needs A

### 🎯 Golden Rule
**If removing require_relative breaks tests → keep it**

---

## Expected Results

### Before
```ruby
require 'uniword'  # Loads 500+ files, 300ms, 60MB
```

### After
```ruby
require 'uniword'  # Loads 20-30 files, <100ms, 15MB
doc = Uniword::Document.new  # Triggers autoload of needed classes
```

---

## Troubleshooting

### "Uninitialized constant" errors

**Cause**: Class not autoloaded
**Fix**: Add autoload declaration to appropriate loader file

### "Circular dependency" errors

**Cause**: A autoloads B, B autoloads A
**Fix**: Use require_relative for one direction

### Tests fail after changes

**Cause**: Something needed isn't loading
**Fix**: Check if format handlers still require_relative'd (they should be)

---

## File Checklist

### Loader Files Status

- [x] `lib/uniword/wordprocessingml.rb` ✅ Done
- [x] `lib/uniword/drawingml.rb` ✅ Done
- [x] `lib/uniword/wp_drawing.rb` ✅ Done
- [x] `lib/uniword/vml.rb` ✅ Done
- [x] `lib/uniword/math.rb` ✅ Done
- [x] `lib/uniword/glossary.rb` ✅ Done
- [ ] `lib/uniword/shared_types.rb` ❌ Create
- [ ] `lib/uniword/content_types.rb` ❌ Create (folder exists)
- [ ] `lib/uniword/document_properties.rb` ❌ Create (folder exists)
- [ ] `lib/uniword/accessibility.rb` ⚠️  Optional
- [ ] `lib/uniword/assembly.rb` ⚠️  Optional
- [ ] `lib/uniword/batch.rb` ⚠️  Optional
- [ ] `lib/uniword/bibliography.rb` ⚠️  Optional
- [ ] `lib/uniword/customxml.rb` ⚠️  Optional

### Main File Updates

- [ ] Convert namespace requires to autoload (9 lines)
- [ ] Add missing top-level class autoloads (~50 classes)
- [ ] Keep format handler require_relative (2 lines)
- [ ] Keep version require_relative (1 line)
- [ ] Keep namespace constants require_relative (1 line)

---

## Testing Checklist

- [ ] `bundle exec rspec` - All tests pass
- [ ] `Uniword::Document.new` - Works without error
- [ ] `Uniword.load('test.docx')` - Loads document
- [ ] Startup performance improved (measure with benchmark)
- [ ] Memory usage reduced (measure with get_process_mem)
- [ ] No breaking changes to public API

---

## Performance Targets

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Files loaded on require | 500-600 | <30 | 95% |
| Startup time | 300ms | <100ms | 70% |
| Base memory | 60MB | <20MB | 67% |
| First Document.new | +50ms | +100ms | Acceptable |

**Note**: First use of autoloaded class is slightly slower (needs to load file), but total time is still faster than loading everything upfront.

---

## Next Action

**Start here**: Create the 3 missing loader files

```bash
# 1. Create shared_types.rb
# 2. Create content_types.rb  
# 3. Create document_properties.rb
# 4. Update lib/uniword.rb
# 5. Run tests
```

See full details in `docs/AUTOLOAD_IMPLEMENTATION_PLAN.md`

---

## Questions?

**Q: Why not autoload everything?**
A: Some things must load eagerly (version, namespaces, self-registering handlers)

**Q: What if I add a new class?**
A: Add one line to the appropriate loader file:
```ruby
autoload :NewClass, File.expand_path('namespace/new_class', __dir__)
```

**Q: Dynamic vs explicit autoload?**
A: Dynamic (Dir.glob) is DRY, explicit is IDE-friendly. Both work!

**Q: Breaking changes?**
A: None! Public API stays exactly the same. Autoload is transparent.

---

**Last Updated**: 2024-12-03
**Status**: Ready to implement