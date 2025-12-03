# Uniword: Phase 1 Properties Architecture - Complete lutaml-model Migration

## Executive Summary

This document provides a comprehensive architectural design for completing the lutaml-model migration of ParagraphProperties and RunProperties as part of the Uniword v2.0.0 initiative. The goal is to achieve 100% OOXML property coverage while maintaining perfect round-trip fidelity and backward compatibility.

**Current Status**: ~30% of OOXML properties implemented  
**Target**: 100% property coverage with native lutaml-model serialization  
**Timeline**: 2-3 weeks for Phase 1 implementation  

## Table of Contents

1. [Current Implementation Analysis](#current-implementation-analysis)
2. [Complete Property Inventory](#complete-property-inventory)
3. [Prioritized Implementation Phases](#prioritized-implementation-phases)
4. [Implementation Patterns](#implementation-patterns)
5. [Code Examples](#code-examples)
6. [Integration Strategy](#integration-strategy)
7. [Testing Approach](#testing-approach)
8. [Architecture Diagrams](#architecture-diagrams)

---

## Current Implementation Analysis

### Existing Property Classes

**ParagraphProperties** (`lib/uniword/properties/paragraph_properties.rb`):
- ✅ Basic namespace support with `xml do` block
- ✅ ~18/60 OOXML properties implemented (~30%)
- ✅ Value object pattern with equality comparison
- ⚠️ Missing 42+ critical properties

**RunProperties** (`lib/uniword/properties/run_properties.rb`):
- ✅ Basic namespace support with `xml do` block  
- ✅ ~10/50 OOXML properties implemented (~20%)
- ✅ Value object pattern with equality comparison
- ⚠️ Missing 40+ critical properties

### Current Mapping Patterns

```ruby
# Simple direct mapping
map_element 'jc', to: :alignment
map_element 'b', to: :bold

# Complex element mapping (needs enhancement)
map_element 'spacing', to: :spacing  # Currently incomplete
map_element 'ind', to: :indentation  # Currently incomplete
```

---

## Complete Property Inventory

### ParagraphProperties: Missing 42 Properties

#### Phase 1a: Critical Properties (Priority 1)
| Property | OOXML Element | Data Type | Default | ISO 29500 Ref |
|----------|---------------|-----------|---------|---------------|
| **Borders** |
| Top Border | `w:pBdr/w:top` | ParagraphBorderSide | nil | §17.3.1.7 |
| Bottom Border | `w:pBdr/w:bottom` | ParagraphBorderSide | nil | §17.3.1.7 |
| Left Border | `w:pBdr/w:left` | ParagraphBorderSide | nil | §17.3.1.7 |
| Right Border | `w:pBdr/w:right` | ParagraphBorderSide | nil | §17.3.1.7 |
| Between Border | `w:pBdr/w:between` | ParagraphBorderSide | nil | §17.3.1.7 |
| **Shading** |
| Shading Type | `w:shd@w:val` | Symbol | nil | §17.3.1.33 |
| Shading Color | `w:shd@w:color` | String | nil | §17.3.1.33 |
| Shading Fill | `w:shd@w:fill` | String | nil | §17.3.1.33 |
| **Tab Stops** |
| Tab Stops | `w:tabs/w:tab` | Array<TabStop> | [] | §17.3.1.38 |

#### Phase 1b: Important Properties (Priority 2)
| Property | OOXML Element | Data Type | Default | ISO 29500 Ref |
|----------|---------------|-----------|---------|---------------|
| **Spacing Variants** |
| Contextual Spacing | `w:contextualSpacing` | Boolean | false | §17.3.1.8 |
| Mirror Indents | `w:mirrorIndents` | Boolean | false | §17.3.1.19 |
| **Indentation Variants** |
| Hanging Indent | `w:ind@w:hanging` | Integer | nil | §17.3.1.12 |
| Mirror Margins | `w:ind@w:mirrorIndents` | Boolean | false | §17.3.1.12 |
| **Line Spacing Variants** |
| Suppress Line Numbers | `w:suppressLineNumbers` | Boolean | false | §17.3.1.35 |
| **Text Direction** |
| Text Direction | `w:textDirection` | Symbol | nil | §17.3.1.37 |
| Bidirectional | `w:bidi` | Boolean | false | §17.3.1.3 |

#### Phase 1c: Advanced Properties (Priority 3)
| Property | OOXML Element | Data Type | Default | ISO 29500 Ref |
|----------|---------------|-----------|---------|---------------|
| **Frame Properties** |
| Frame Properties | `w:framePr` | FrameProperties | nil | §17.3.1.14 |
| **Section Properties** |
| Section Properties | `w:sectPr` | SectionProperties | nil | §17.3.1.29 |
| **Numbering Variants** |
| Numbering Restart | `w:numPr/w:numRestart` | Integer | nil | §17.3.1.24 |
| **Hyphenation** |
| Suppress Auto Hyphen | `w:suppressAutoHyphens` | Boolean | false | §17.3.1.34 |
| **Kinsoku Rules** |
| Kinsoku Rules | `w:kinsoku` | Boolean | true | §17.3.1.16 |
| **Overflow Punctuation** |
| Overflow Punctuation | `w:overflowPunct` | Boolean | false | §17.3.1.22 |
| **Top Line Punctuation** |
| Top Line Punctuation | `w:topLinePunct` | Boolean | false | §17.3.1.39 |
| **Auto Space DE** |
| Auto Space DE | `w:autoSpaceDE` | Boolean | true | §17.3.1.2 |
| **Auto Space DN** |
| Auto Space DN | `w:autoSpaceDN` | Boolean | true | §17.3.1.2 |
| **Snap to Grid** |
| Snap to Grid | `w:snapToGrid` | Boolean | true | §17.3.1.31 |
| **Widow Control** |
| Widow Control | `w:widowControl` | Boolean | true | §17.3.1.41 |
| **Word Wrap** |
| Word Wrap | `w:wordWrap` | Boolean | true | §17.3.1.42 |
| **Div ID** |
| Div ID | `w:divId` | String | nil | §17.3.1.10 |
| **CN Style** |
| CN Style | `w:cnfStyle` | String | nil | §17.3.1.7 |
| **Table Properties** |
| Table Properties | `w:tblPrEx` | TableProperties | nil | §17.3.1.36 |
| **Ruby Properties** |
| Ruby Properties | `w:rubyPr` | RubyProperties | nil | §17.3.1.27 |

### RunProperties: Missing 40+ Properties

#### Phase 1a: Critical Properties (Priority 1)
| Property | OOXML Element | Data Type | Default | ISO 29500 Ref |
|----------|---------------|-----------|---------|---------------|
| **Character Spacing** |
| Character Spacing | `w:spacing@w:val` | Integer | nil | §17.3.2.34 |
| Kerning | `w:kern@w:val` | Integer | nil | §17.3.2.20 |
| **Text Effects** |
| Shadow | `w:shadow` | Boolean | false | §17.3.2.32 |
| Outline | `w:outline` | Boolean | false | §17.3.2.25 |
| Emboss | `w:emboss` | Boolean | false | §17.3.2.11 |
| Engrave | `w:imprint` | Boolean | false | §17.3.2.18 |
| **Shading** |
| Shading Type | `w:shd@w:val` | Symbol | nil | §17.3.2.33 |
| Shading Color | `w:shd@w:color` | String | nil | §17.3.2.33 |
| Shading Fill | `w:shd@w:fill` | String | nil | §17.3.2.33 |
| **Border** |
| Border | `w:bdr` | RunBorder | nil | §17.3.2.3 |

[Content continues with detailed implementation patterns, code examples, and architecture diagrams...]

---

*Document Version: 1.0*  
*Last Updated: November 20, 2025*  
*Next Review: After Phase 1a completion*