# Plan: Fix Theme Extraction Specs

## Problem

Nine tests in `theme_extraction_spec.rb` fail related to theme and style application.

## Failing Tests

1. `apply_theme_from` (line 116) - method doesn't exist
2. `apply_styles_from` (line 138) - method doesn't exist
3. `apply_template` (line 160) - method doesn't exist
4. `import_from_document skips existing styles` (line 196)
5. `merge keeps existing styles by default` (line 225)
6. `merge replaces existing styles when requested` (line 239)
7. `merge renames conflicting styles when requested` (line 251)
8. `theme round-trips through DOCX` (line 297)
9. `using theme colors in styles` (line 339)

## Root Cause Analysis

### Category 1: Missing Methods (lines 116, 138, 160)

Tests expect `DocumentRoot` to have methods that don't exist:
- `apply_theme_from` - undefined
- `apply_styles_from` - undefined
- `apply_template` - undefined

These are feature gaps - the methods need to be implemented.

### Category 2: Theme Round-Trip Issues (line 297)

Test sets `doc.theme.color_scheme.colors[:accent1] = '0066CC'` but after save/load gets `'4472C4'`.

Issues:
1. Theme serialization might not properly save custom color values
2. Loaded document might use embedded default theme instead of custom values
3. Theme color handling might involve theme color references (thematicColor) vs direct RGB

### Category 3: StylesConfiguration Merge Issues (lines 196, 225, 239, 251)

Tests for `StylesConfiguration.merge` functionality failing.

### Category 4: Theme Colors in Styles (line 339)

Theme color usage in styles not working correctly.

## Fix Approach (Model-Driven)

### 1. Missing Methods

These are feature implementations, not fixes. Options:

**Option A**: Implement the missing methods on DocumentRoot:
- `apply_theme_from(source_path)` - Load theme from another document
- `apply_styles_from(source_path, **options)` - Copy styles from another document
- `apply_template(path)` - Apply both theme and styles from template

**Option B**: Remove tests that require unimplemented features

Given "model-driven" approach, Option A is preferred if the features are part of the design.

### 2. Theme Round-Trip Issue

This is likely a serialization issue. The `Theme` class needs to properly serialize its colors.

Check:
1. Does `ThemeColorScheme` properly serialize `colors` hash?
2. Does the color value get properly stored in the XML?
3. Is the correct theme being loaded on `Uniword.load`?

### 3. StylesConfiguration Merge

This involves understanding how styles are merged when copying between documents.

## Investigation Steps

1. Check `Theme` and `ThemeColorScheme` serialization
2. Verify `color_scheme.colors` attribute mapping
3. Understand how `Uniword.load` chooses which theme to use
4. Check `StylesConfiguration.merge` implementation

## Files to Investigate

- `lib/uniword/drawingml/theme.rb`
- `lib/uniword/drawingml/theme_color_scheme.rb`
- `lib/uniword/wordprocessingml/styles_configuration.rb`
- `lib/uniword/wordprocessingml/document_root.rb`

## Note

These are complex issues involving multiple interconnected systems. Some may require significant implementation work or architectural changes. The "model-driven" approach means these should work through proper attribute mappings and serialization, not through ad-hoc setter logic.

## Priority

1. **High**: Theme round-trip (line 297) - core serialization issue
2. **Medium**: Missing methods - feature implementation needed
3. **Low**: Merge operations - complex logic issue
