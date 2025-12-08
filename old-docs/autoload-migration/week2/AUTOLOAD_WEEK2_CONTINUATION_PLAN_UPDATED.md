# Uniword: Week 2 Continuation Plan - Model-Driven Package Architecture

**Goal**: Eliminate ALL handler anti-patterns and implement pure model-driven Package architecture for ALL Word file formats.

**Principle**: Each file format (DOCX, DOTX, DOTM, THMX, MHTML, DOC) has its own Package model class. A PackageRegistry maps extensions/signatures to Package classes. NO orchestrators, NO handlers.

---

## Architecture Vision

### Current (Session 1 Complete)
```
DocumentFactory → DocxPackage (for .docx only)
                  ↓
                  Remaining: handlers for .dotx, .dotm, .thmx, .mht, .doc
```

### Target (After Week 2)
```
DocumentFactory → PackageRegistry → Package classes
                                    ├── DocxPackage (.docx)
                                    ├── DotxPackage (.dotx, .dotm)
                                    ├── ThmxPackage (.thmx)
                                    └── MhtmlPackage (.mht, .doc, .mhtml)
```

**Key**: Each Package class is a full lutaml-model with `from_file()` and `to_file()` methods. Registry is just a lookup table, NOT an orchestrator.

---

## Phase 1: Package Classes for All Formats (6 hours)

### Session 2: DOTX/DOTM Package (2 hours)

**Create**: `lib/uniword/ooxml/dotx_package.rb`
- Inherits from or similar to DocxPackage
- Supports both .dotx (template) and .dotm (macro-enabled template)
- Loads StyleSets from word/styles.xml
- `from_file(path)` → StyleSet or Document
- `to_file(content, path)` → saves as .dotx/.dotm

**Features**:
- Parse document.xml (if present)
- Parse styles.xml → StylesConfiguration
- Parse theme1.xml → Theme
- Support glossary.xml (building blocks)

### Session 3: THMX Package (1.5 hours)

**Create**: `lib/uniword/ooxml/thmx_package.rb`
- Standalone theme package (different structure than DOCX)
- XML structure: theme/theme1.xml (no word/ directory)
- `from_file(path)` → Theme
- `to_file(theme, path)` → saves as .thmx

**Structure**:
```
package.thmx (ZIP)
├── _rels/.rels
├── [Content_Types].xml
└── theme/
    └── theme1.xml
```

### Session 4: MHTML Package (2.5 hours)

**Create**: `lib/uniword/ooxml/mhtml_package.rb`
- MIME multipart format (not ZIP)
- Supports .mht, .mhtml, .doc (legacy)
- Uses Infrastructure::MimeParser
- `from_file(path)` → Document
- `to_file(document, path)` → saves as MHTML

**Detection**: .doc files can be either:
1. MHTML (check for MIME-Version: header)
2. Binary DOC (not supported - raise error)

---

## Phase 2: Package Registry System (2 hours)

### Session 5: PackageRegistry (2 hours)

**Create**: `lib/uniword/package_registry.rb`

**Architecture**:
```ruby
class PackageRegistry
  # STATIC registry (class-level, not instance)
  @packages = {}

  def self.register(extensions, package_class)
    extensions.each { |ext| @packages[ext] = package_class }
  end

  def self.package_for_extension(ext)
    @packages[ext.downcase] || raise(UnknownFormatError, ext)
  end

  def self.package_for_path(path)
    ext = File.extname(path).downcase
    package_for_extension(ext)
  end
end

# Auto-registration (in each package file)
PackageRegistry.register(['.docx'], DocxPackage)
PackageRegistry.register(['.dotx', '.dotm'], DotxPackage)
PackageRegistry.register(['.thmx'], ThmxPackage)
PackageRegistry.register(['.mht', '.mhtml', '.doc'], MhtmlPackage)
```

**Key**: Registry is just a lookup table. Package classes handle ALL logic themselves.

**Update DocumentFactory**:
```ruby
def from_file(path)
  package_class = PackageRegistry.package_for_path(path)
  package_class.from_file(path)
end
```

**Update DocumentWriter**:
```ruby
def save(path)
  package_class = PackageRegistry.package_for_path(path)
  package_class.to_file(document, path)
end
```

---

## Phase 3: Delete Formats Directory (1 hour)

### Session 6: Final Cleanup (1 hour)

**Delete**:
1. `lib/uniword/formats/base_handler.rb`
2. `lib/uniword/formats/format_handler_registry.rb`
3. `lib/uniword/formats/mhtml_handler.rb`
4. `lib/uniword/formats/` directory (empty)

**Update `lib/uniword.rb`**:
- Remove all Formats module autoloads
- Add PackageRegistry autoload

**Verify**:
```bash
# Should not exist
ls lib/uniword/formats/
# → No such file or directory ✅
```

---

## Phase 4: Documentation (1 hour)

### Session 7: Update Documentation (1 hour)

**Update `README.adoc`**:
- Document package architecture
- Show examples for each format
- Explain PackageRegistry

**Create `docs/PACKAGE_ARCHITECTURE.md`**:
```markdown
# Package Architecture

## Overview
Each file format has its own Package model class:
- DocxPackage: .docx files
- DotxPackage: .dotx, .dotm templates
- ThmxPackage: .thmx themes
- MhtmlPackage: .mht, .mhtml, .doc (legacy)

## PackageRegistry
Static registry mapping extensions to Package classes.
```

**Move to old-docs/**:
- `AUTOLOAD_WEEK2_SESSION1_PROMPT.md` (completed)
- Any temporary handler documentation

---

## Implementation Status Tracker

| Phase | Session | Task | Duration | Status |
|-------|---------|------|----------|--------|
| **1** | **1** | **Merge DocxHandler → DocxPackage** | **0.2h** | **✅ COMPLETE** |
| 1 | 2 | Create DotxPackage | 2h | ⏳ Pending |
| 1 | 3 | Create ThmxPackage | 1.5h | ⏳ Pending |
| 1 | 4 | Create MhtmlPackage | 2.5h | ⏳ Pending |
| **2** | **5** | **PackageRegistry + Integration** | **2h** | **⏳ Pending** |
| **3** | **6** | **Delete formats/ directory** | **1h** | **⏳ Pending** |
| **4** | **7** | **Documentation** | **1h** | **⏳ Pending** |
| **Total** | **7** | **Complete Architecture** | **10.2h** | **14% Complete** |

---

## Success Criteria

### By End of Week 2:
- [ ] All 5 package classes exist (Docx, Dotx, Thmx, Mhtml) ✅ 1/5 complete
- [ ] PackageRegistry implemented and working
- [ ] DocumentFactory uses registry for all formats
- [ ] DocumentWriter uses registry for all formats
- [ ] `lib/uniword/formats/` directory deleted
- [ ] All tests passing (258/258, 32 pre-existing failures)
- [ ] Documentation updated

### Architecture Quality:
- [ ] 100% model-driven (no handlers, no orchestrators)
- [ ] MECE (each package has ONE responsibility)
- [ ] Open/Closed (easy to add new formats via registry)
- [ ] Separation of concerns (registry ≠ package ≠ factory)

---

## Format Support Matrix

| Format | Extension(s) | Package Class | Structure | Status |
|--------|-------------|---------------|-----------|--------|
| DOCX | .docx | DocxPackage | ZIP + OOXML | ✅ Complete |
| DOTX | .dotx | DotxPackage | ZIP + OOXML | ⏳ Session 2 |
| DOTM | .dotm | DotxPackage | ZIP + OOXML | ⏳ Session 2 |
| THMX | .thmx | ThmxPackage | ZIP + Theme | ⏳ Session 3 |
| MHTML | .mht, .mhtml | MhtmlPackage | MIME | ⏳ Session 4 |
| DOC (MHTML) | .doc | MhtmlPackage | MIME/Binary | ⏳ Session 4 |

---

## Next Session Start

**Session 2 Prompt**: See `AUTOLOAD_WEEK2_SESSION2_PROMPT.md`

**Estimated Total Time**: 10.2 hours (compressed from 15+ hours)
**Current Progress**: Session 1/7 complete (14%)
**Target**: Complete by end of Week 2

---

**Created**: December 8, 2024
**Status**: Session 1 complete, ready for Session 2
**Architecture**: Model-driven packages with static registry