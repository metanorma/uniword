# README.adoc Update Plan - Autoload Migration

**Created**: December 8, 2024
**Status**: Planning
**Target**: Update documentation after Package migration complete

---

## Changes Needed

### 1. Remove Handler References

**Current (WRONG)**:
```adoc
Uniword supports multiple formats through format handlers:
- DocxHandler for DOCX files
- MhtmlHandler for MHTML files
```

**Updated (CORRECT)**:
```adoc
Uniword supports multiple formats with automatic detection:
- DOCX (Word 2007+) - ZIP-based Office Open XML
- MHTML (Word 2003+) - MIME HTML format
```

**Files/Sections**:
- Architecture section
- Format support section
- Any code examples using handlers

---

### 2. Update Package API Examples

**Current (WRONG)**:
```ruby
# Old handler-based approach
handler = Uniword::Formats::DocxHandler.new
doc = handler.load('document.docx')
handler.save(doc, 'output.docx')
```

**Updated (CORRECT)**:
```ruby
# New Package-based approach
doc = Uniword::Document.from_file('document.docx')
doc.to_file('output.docx')

# Or using Package directly
pkg = Uniword::DocxPackage.from_file('document.docx')
pkg.to_file('output.docx')
```

**Files/Sections**:
- Basic Usage examples
- API Reference
- Code examples throughout

---

### 3. Add Format Detection Section

**New Section to Add**:

```adoc
=== Format Detection

Uniword automatically detects document format using:

1. **File signature analysis** (magic bytes)
   - DOCX: ZIP signature (PK\x03\x04)
   - MHTML: MIME-Version header

2. **Extension fallback** if signature unclear
   - `.docx` → DOCX format
   - `.doc`, `.mht`, `.mhtml` → MHTML format

3. **Explicit format specification**
```ruby
# Automatic detection
doc = Uniword::Document.from_file('unknown_file')

# Explicit format
pkg = Uniword::DocxPackage.from_file('file.bin')
pkg = Uniword::MhtmlPackage.from_file('legacy.doc')
```

**Location**: After Basic Usage, before Advanced Features

---

### 4. Update Architecture Documentation

**Add Package Hierarchy Diagram**:

```adoc
=== Package Architecture

Uniword uses a Package-based architecture for format handling:

[source]
----
PackageFile (abstract)
├── DocxPackage (DOCX format)
│   ├── Handles ZIP extraction/packaging
│   ├── Manages document.xml, styles.xml, etc.
│   └── Relationships and content types
│
└── MhtmlPackage (MHTML format)
    ├── Handles MIME multipart structure
    ├── Manages HTML and embedded resources
    └── Converts to/from DOCX structure
----

**Key Classes**:
- `PackageFile` - Base abstract class
- `DocxPackage` - DOCX ZIP package handling
- `MhtmlPackage` - MHTML MIME handling
- `DocumentFactory` - Factory with format detection
```

**Location**: Architecture section

---

### 5. Remove Handler Registry

**Remove**:
- Any mention of `FormatHandlerRegistry`
- Examples showing handler registration
- Handler plugin system documentation

**Keep**:
- `DocumentFactory` (this is the replacement)
- Format detection system
- Package architecture

---

### 6. Update Installation/Setup

**Check if handlers referenced in**:
- [ ] Gemspec dependencies
- [ ] Installation instructions
- [ ] Configuration examples
- [ ] Environment setup

**Most likely**: No changes needed (handlers were internal)

---

### 7. Add Migration Guide

**New Section** (optional, could be separate doc):

```adoc
== Migrating from Handler-Based API

If you're upgrading from Uniword < 2.0:

**Before** (Handler-based):
```ruby
require 'uniword'
require 'uniword/formats/docx_handler'

handler = Uniword::Formats::DocxHandler.new
doc = handler.load('input.docx')
handler.save(doc, 'output.docx')
```

**After** (Package-based):
```ruby
require 'uniword'

doc = Uniword::Document.from_file('input.docx')
doc.to_file('output.docx')

# Or with explicit package
pkg = Uniword::DocxPackage.from_file('input.docx')
pkg.to_file('output.docx')
```

**Key Changes**:
- Removed: `Formats::DocxHandler`, `Formats::MhtmlHandler`
- Added: `DocxPackage`, `MhtmlPackage`
- API: `.from_file()` / `.to_file()` instead of handler methods
```

**Location**: End of README or separate MIGRATION.md

---

### 8. Update Code Examples

**Search for**:
```bash
grep -n "Handler\|handler" README.adoc
grep -n "Formats::" README.adoc
grep -n "load(" README.adoc
grep -n "save(" README.adoc
```

**Replace with Package API equivalents**

---

## Verification Checklist

After updates:

- [ ] No mentions of `DocxHandler` or `MhtmlHandler`
- [ ] No mentions of `FormatHandlerRegistry`
- [ ] All code examples use Package API
- [ ] Format detection documented
- [ ] Package architecture documented
- [ ] Migration guide present (if needed)
- [ ] Examples tested and working
- [ ] Links to related docs updated

---

## Timeline

**When to Update**:
- After Week 3 Session 3 complete (Wordprocessingml conversion)
- Before v2.0 release
- Coordinated with CHANGELOG update

**Estimated Time**: 1-2 hours

---

**Created**: December 8, 2024
**Status**: Planning - Execute after Session 3