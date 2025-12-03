# Phase 3 Week 2: Theme Round-Trip Implementation Plan

**Created**: November 30, 2024
**Status**: Ready to Start
**Objective**: Achieve 53/61 files round-trip (24 StyleSets + 29 Themes)

## Current Status

**Week 1 Complete! (2 Days Early)** ✅
- 25/25 properties implemented (100%)
- 24/24 StyleSets round-trip perfect
- 168/168 tests passing
- All architecture patterns validated

**Week 2 Goal**: Add 29 theme files to achieve 53/61 (87%) completion

## Architecture Overview

### Current Theme Support

**What Works:**
- ✅ Theme loading from .thmx files (ZIP packages)
- ✅ Theme loading from YAML files (28 bundled themes)
- ✅ Theme application to documents
- ✅ ColorScheme and FontScheme models
- ✅ Theme model with lutaml-model serialization

**What's Missing:**
- ❌ Theme serialization to XML (theme1.xml)
- ❌ Theme packaging to .thmx files
- ❌ Theme round-trip tests
- ❌ Package architecture (DotxPackage, ThmxPackage)

### Required Architecture: Package Hierarchy

```
PackageFile (abstract base class)
├── attributes: path, extracted_dir
├── methods: extract, package, cleanup
│
├── DotxPackage (Word template .dotx files)
│   ├── StyleSetPackage (specialized for style-sets/)
│   │   ├── attribute: styleset, StyleSet
│   │   ├── loads word/styles.xml → StyleSet
│   │   ├── saves StyleSet → word/styles.xml
│   │   └── round-trip: load → save → compare
│   │
│   ├── QuickStylePackage (specialized for quick-styles/)
│   │   └── (same structure as StyleSetPackage)
│   │
│   └── DocumentElementPackage (for document-elements/)
│       └── (Week 3)
│
└── ThmxPackage (Theme .thmx files)
    └── ThemePackage (specialized)
        ├── attribute: theme, Theme
        ├── loads theme/theme1.xml → Theme
        ├── saves Theme → theme/theme1.xml
        └── round-trip: load → save → compare
```

### Critical Files

**Existing (to understand):**
- `lib/uniword/theme.rb` - Theme model
- `lib/uniword/theme/theme_loader.rb` - Loads themes from YAML/packages
- `lib/uniword/theme/theme_package_reader.rb` - Extracts .thmx files

**To Create:**
- `lib/uniword/ooxml/package_file.rb` - Abstract base
- `lib/uniword/ooxml/dotx_package.rb` - .dotx handler
- `lib/uniword/ooxml/thmx_package.rb` - .thmx handler
- `lib/uniword/ooxml/styleset_package.rb` - StyleSet specialization
- `lib/uniword/ooxml/theme_package.rb` - Theme specialization
- `lib/uniword/serialization/theme_serializer.rb` - Theme → XML
- `spec/uniword/theme_roundtrip_spec.rb` - Round-trip tests

## Week 2 Implementation Plan

### Day 4: Package Architecture (8 hours)

**Phase 1: Base Classes (3 hours)**

1. Create `PackageFile` abstract base class:
   ```ruby
   class PackageFile
     attr_reader :path, :extracted_dir
     
     def initialize(path:)
       @path = path
       @extracted_dir = nil
     end
     
     def extract
       # Unzip to temp directory
     end
     
     def package(output_path)
       # Zip from temp directory
     end
     
     def cleanup
       # Remove temp directory
     end
     
     # Abstract methods (to be overridden)
     def load_content
       raise NotImplementedError
     end
     
     def save_content(content)
       raise NotImplementedError
     end
   end
   ```

2. Create `DotxPackage` class:
   - Inherits from `PackageFile`
   - Knows about word/ directory structure
   - Handles [Content_Types].xml
   - Handles .rels files

3. Create `ThmxPackage` class:
   - Inherits from `PackageFile`
   - Knows about theme/ directory structure
   - Handles theme1.xml location

**Phase 2: Specialized Packages (3 hours)**

4. Create `StyleSetPackage`:
   - Inherits from `DotxPackage`
   - `load_content` → parses word/styles.xml → StyleSet
   - `save_content(styleset)` → serializes StyleSet → word/styles.xml
   - Wrapper around existing StyleSetLoader logic

5. Create `ThemePackage`:
   - Inherits from `ThmxPackage`
   - `load_content` → parses theme/theme1.xml → Theme
   - `save_content(theme)` → serializes Theme → theme/theme1.xml
   - New serialization logic needed

**Phase 3: Integration (2 hours)**

6. Refactor existing loaders to use new packages:
   - `StyleSet.from_dotx(path)` → `StyleSetPackage.new(path: path).load_content`
   - `Theme.from_thmx(path)` → `ThemePackage.new(path: path).load_content`

7. Add package tests:
   - Test extraction and packaging
   - Test load/save cycles
   - Test cleanup

### Day 5: Theme Serialization (8 hours)

**Phase 1: Theme XML Structure (2 hours)**

Understand theme1.xml structure:
```xml
<a:theme xmlns:a="http://schemas...drawingml/2006/main" name="Atlas">
  <a:themeElements>
    <a:clrScheme name="Atlas">
      <a:dk1><a:sysClr val="windowText"/></a:dk1>
      <a:lt1><a:sysClr val="window"/></a:lt1>
      <a:dk2><a:srgbClr val="1F497D"/></a:dk2>
      <!-- 12 theme colors total -->
    </a:clrScheme>
    <a:fontScheme name="Atlas">
      <a:majorFont>
        <a:latin typeface="Century Gothic"/>
        <!-- other scripts -->
      </a:majorFont>
      <a:minorFont>
        <a:latin typeface="Century Gothic"/>
      </a:minorFont>
    </a:fontScheme>
    <a:fmtScheme name="Office">
      <!-- Fill/line/effect styles -->
    </a:fmtScheme>
  </a:themeElements>
</a:theme>
```

**Phase 2: Theme Model Updates (2 hours)**

8. Update `Theme` model for serialization:
   - Ensure all attributes have xml mappings
   - Add DrawingML namespace (a:)
   - Test ColorScheme serialization
   - Test FontScheme serialization

9. Add FormatScheme model (if needed):
   - Basic structure for fmtScheme
   - May defer full implementation to v2.0

**Phase 3: Theme Serializer (3 hours)**

10. Create `ThemeSerializer`:
    ```ruby
    class ThemeSerializer
      def serialize(theme)
        # Theme → theme1.xml (DrawingML)
      end
    end
    ```

11. Integrate with ThemePackage:
    - `save_content(theme)` uses ThemeSerializer
    - Writes to theme/theme1.xml

**Phase 4: Testing (1 hour)**

12. Test theme serialization:
    - Load Atlas.yml
    - Serialize to XML
    - Validate against reference theme1.xml
    - Check namespace correctness

### Day 6: Theme Round-Trip Tests (6 hours)

**Phase 1: Test Setup (2 hours)**

13. Create `spec/uniword/theme_roundtrip_spec.rb`:
    ```ruby
    RSpec.describe 'Theme Round-Trip' do
      THEME_DIR = 'references/word-package/office-themes'
      
      Dir.glob("#{THEME_DIR}/*.thmx").each do |theme_path|
        it "round-trips #{File.basename(theme_path)}" do
          # Load
          package = ThemePackage.new(path: theme_path)
          theme = package.load_content
          
          # Save
          output = 'tmp/roundtrip_theme.thmx'
          package.save_content(theme)
          package.package(output)
          
          # Compare
          expect(File.exist?(output)).to be true
          # Semantic comparison of theme XML
        end
      end
    end
    ```

**Phase 2: Implement Tests (2 hours)**

14. Run tests, fix failures:
    - Missing attributes in Theme model
    - Namespace issues (a: prefix)
    - Color/Font serialization bugs

**Phase 3: Semantic Comparison (2 hours)**

15. Add Canon-based XML comparison:
    - Extract theme1.xml from original
    - Extract theme1.xml from round-trip
    - Compare using Canon (ignores whitespace/order)
    - Assert `be_xml_equivalent_to`

### Day 7: Complete All 29 Themes (6 hours)

**Phase 1: Batch Testing (2 hours)**

16. Run all 29 theme tests:
    - Identify common failures
    - Group by failure type
    - Prioritize fixes

**Phase 2: Bug Fixes (3 hours)**

17. Fix systematic issues:
    - Color scheme serialization
    - Font scheme serialization
    - Theme element ordering
    - Namespace handling

18. Fix edge cases:
    - Themes with custom colors
    - Themes with special fonts
    - Theme variants

**Phase 3: Validation (1 hour)**

19. Final verification:
    - All 29 tests passing
    - File sizes reasonable (< 10% variance)
    - XML validates against schema

### Day 8: Documentation & Cleanup (4 hours)

**Phase 1: Update Documentation (2 hours)**

20. Update README.adoc:
    - Document package architecture
    - Document theme round-trip
    - Add usage examples

21. Create package architecture diagram:
    - Show class hierarchy
    - Show file flow
    - Document in docs/PACKAGE_ARCHITECTURE.md

**Phase 2: Code Cleanup (1 hour)**

22. Refactor and polish:
    - Remove debug code
    - Add documentation comments
    - Run Rubocop, fix style issues

**Phase 3: Archive Old Docs (1 hour)**

23. Move to old-docs/:
    - PHASE2_*.md (completed)
    - PHASE3_SESSION*.md (completed)
    - NAMESPACE_*.md (outdated)
    - Temporary work completion docs

## Success Criteria

### Must Have (Required)
- [ ] PackageFile hierarchy implemented
- [ ] ThemePackage with load/save
- [ ] Theme serialization to theme1.xml
- [ ] 29/29 theme round-trip tests passing
- [ ] Total: 53/61 files (87%)

### Should Have (Important)
- [ ] Semantic XML comparison with Canon
- [ ] Documentation updated
- [ ] Code cleanup complete
- [ ] Old docs archived

### Nice to Have (Optional)
- [ ] Performance benchmarks
- [ ] Theme validation against schema
- [ ] Error messages for missing elements

## Risk Mitigation

### Risk 1: DrawingML Namespace Complexity
**Impact**: High
**Likelihood**: Medium
**Mitigation**: 
- Study existing theme1.xml files carefully
- Use lutaml-model namespace support
- Test incrementally

### Risk 2: FormatScheme Incomplete
**Impact**: Medium
**Likelihood**: High
**Mitigation**:
- Defer full FormatScheme to v2.0
- Basic structure sufficient for round-trip
- Focus on ColorScheme/FontScheme first

### Risk 3: Time Pressure
**Impact**: Medium
**Likelihood**: Low (ahead of schedule!)
**Mitigation**:
- We're 2 days ahead
- Can extend to Day 9-10 if needed
- Compress less critical tasks

## Timeline Summary

```
Day 4: Package Architecture        [████████] 8h
Day 5: Theme Serialization          [████████] 8h
Day 6: Round-Trip Tests             [██████  ] 6h
Day 7: Complete 29 Themes           [██████  ] 6h
Day 8: Documentation & Cleanup      [████    ] 4h
─────────────────────────────────────────────
Total:                              32 hours
```

**Expected Completion**: End of Day 8 (November 30 + 5 days = December 5)

## Next Week Preview (Week 3)

After Week 2 completion (53/61 files):
- Week 3: Document elements (8 files)
- Focus: Headers, footers, bibliography, TOC, etc.
- Target: 61/61 files (100%)

## Notes

- Week 1 finished 2 days early (Day 3 vs Day 5)
- This gives buffer for Week 2 complexity
- Package architecture is critical for extensibility
- Theme serialization simpler than StyleSet (fewer properties)