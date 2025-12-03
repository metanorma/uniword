# Continue Session 10: Chart Namespace

## Context

You are continuing Uniword v2.0 development. Session 9 completed SpreadsheetML namespace with 83 elements. The project is now at 71.3% completion (542/760 elements, 15/30 namespaces).

**Current Status**:
- Progress: 71.3% (542/760 elements, 15/30 namespaces)
- Completed: WordProcessingML (100), Math (65), DrawingML (92), Picture (10), Relationships (5), WP Drawing (27), Content Types (3), VML (15), Office (40), VML Office (25), Document Properties (20), Word 2010 (25), Word 2013 (20), Word 2016 (15), SpreadsheetML (83)
- Infrastructure: SchemaLoader, ModelGenerator, autoload pattern - all working perfectly
- Velocity: 83 elements in Session 9 = 41 elements/hour (2.7x Session 8!)

## Session 10 Objectives

**Target**: Add 70 elements (Chart: c:)
**Duration**: 4-5 hours
**Expected Progress**: 71.3% → 80.5%

### Task 1: Create Chart Schema (+70 elements)

**File**: `config/ooxml/schemas/chart.yml`

Chart namespace (c:) provides comprehensive chart and graph support for data visualization in documents.

**Namespace**:
```yaml
namespace:
  uri: 'http://schemas.openxmlformats.org/drawingml/2006/chart'
  prefix: 'c'
  description: 'Chart - Chart and graph definitions for data visualization'
```

**Key Element Groups** (70 total):

#### 1. Chart Container (5 elements)
- `chartSpace` - Chart space root element
- `chart` - Chart container
- `title` - Chart title
- `autoTitleDeleted` - Auto title deleted flag
- `plotArea` - Plot area container

#### 2. Chart Types (15 elements)
- `barChart` - Bar chart
- `bar3DChart` - 3D bar chart
- `lineChart` - Line chart
- `line3DChart` - 3D line chart
- `pieChart` - Pie chart
- `pie3DChart` - 3D pie chart
- `areaChart` - Area chart
- `area3DChart` - 3D area chart
- `scatterChart` - Scatter chart
- `radarChart` - Radar chart
- `surfaceChart` - Surface chart
- `surface3DChart` - 3D surface chart
- `doughnutChart` - Doughnut chart
- `bubbleChart` - Bubble chart
- `stockChart` - Stock chart

#### 3. Series & Data (10 elements)
- `ser` - Chart series
- `idx` - Series index
- `order` - Series order
- `tx` - Series text
- `cat` - Category axis data
- `val` - Value axis data
- `xVal` - X values
- `yVal` - Y values
- `bubbleSize` - Bubble size
- `numRef` - Number reference

#### 4. Axes (12 elements)
- `catAx` - Category axis
- `valAx` - Value axis
- `dateAx` - Date axis
- `serAx` - Series axis
- `axId` - Axis ID
- `scaling` - Scaling properties
- `orientation` - Axis orientation
- `axPos` - Axis position
- `majorGridlines` - Major gridlines
- `minorGridlines` - Minor gridlines
- `numFmt` - Number format
- `tickLblPos` - Tick label position

#### 5. Legend & Labels (8 elements)
- `legend` - Legend container
- `legendPos` - Legend position
- `legendEntry` - Legend entry
- `dLbls` - Data labels
- `dLbl` - Individual data label
- `showLegendKey` - Show legend key
- `showVal` - Show value
- `showCatName` - Show category name

#### 6. Styling & Formatting (10 elements)
- `spPr` - Shape properties
- `txPr` - Text properties
- `style` - Chart style
- `clrMapOvr` - Color map override
- `marker` - Data marker
- `markerStyle` - Marker style
- `markerSize` - Marker size
- `smooth` - Smooth lines
- `explosion` - Pie explosion
- `gapWidth` - Gap width

#### 7. Advanced Features (10 elements)
- `trendline` - Trendline
- `trendlineType` - Trendline type
- `errBars` - Error bars
- `errDir` - Error direction
- `errBarType` - Error bar type
- `upDownBars` - Up/down bars
- `hiLowLines` - High/low lines
- `dropLines` - Drop lines
- `layout` - Chart layout
- `plotVisOnly` - Plot visible only

**Schema Structure Example**:
```yaml
elements:
  chartSpace:
    class_name: ChartSpace
    description: 'Chart space root element'
    attributes:
      - name: chart
        type: Chart
        xml_name: chart
        required: true
        description: 'Chart container'
      - name: sp_pr
        type: String
        xml_name: spPr
        description: 'Shape properties'
      - name: tx_pr
        type: String
        xml_name: txPr
        description: 'Text properties'
  
  chart:
    class_name: Chart
    description: 'Chart container'
    attributes:
      - name: title
        type: Title
        xml_name: title
        description: 'Chart title'
      - name: auto_title_deleted
        type: AutoTitleDeleted
        xml_name: autoTitleDeleted
        description: 'Auto title deleted flag'
      - name: plot_area
        type: PlotArea
        xml_name: plotArea
        required: true
        description: 'Plot area'
      - name: legend
        type: Legend
        xml_name: legend
        description: 'Legend'
  
  barChart:
    class_name: BarChart
    description: 'Bar chart definition'
    attributes:
      - name: bar_dir
        type: BarDirection
        xml_name: barDir
        required: true
        description: 'Bar direction (bar, col)'
      - name: grouping
        type: Grouping
        xml_name: grouping
        description: 'Grouping (clustered, stacked, percentStacked, standard)'
      - name: series
        type: Series
        collection: true
        xml_name: ser
        description: 'Chart series'
      - name: gap_width
        type: GapWidth
        xml_name: gapWidth
        description: 'Gap width between bars'
      - name: overlap
        type: Overlap
        xml_name: overlap
        description: 'Overlap percentage'
```

### Task 2: Generate Classes

Use proven generation pattern:

```ruby
require_relative 'lib/uniword/schema/model_generator'

gen = Uniword::Schema::ModelGenerator.new('chart')
results = gen.generate_all
puts "Generated #{results.size} Chart classes"
```

### Task 3: Create Autoload Index

**File**: `lib/generated/chart.rb`

Pattern:
```ruby
module Uniword
  module Generated
    module Chart
      autoload :ChartSpace, File.expand_path('chart/chart_space', __dir__)
      autoload :Chart, File.expand_path('chart/chart', __dir__)
      # ... 68 more autoloads
    end
  end
end
```

### Task 4: Test Everything

Create `test_session10_autoload.rb`:
```ruby
require_relative 'lib/generated/chart'

puts "Testing Chart namespace (c:)..."
sample_classes = [
  Uniword::Generated::Chart::ChartSpace,
  Uniword::Generated::Chart::Chart,
  Uniword::Generated::Chart::BarChart,
  Uniword::Generated::Chart::LineChart,
  Uniword::Generated::Chart::PieChart,
  Uniword::Generated::Chart::Legend,
  Uniword::Generated::Chart::Series
]
puts "✅ Loaded #{sample_classes.size} sample classes"
```

### Task 5: Update Documentation

1. Update `docs/V2.0_IMPLEMENTATION_STATUS.md`:
   - Progress: 71.3% → 80.5%
   - Elements: 542 → 612 (+70)
   - Namespaces: 15 → 16 (+1)

2. Create `SESSION_10_SUMMARY.md`

3. Move Session 9 docs to `old-docs/`:
   - `SESSION_9_SUMMARY.md`
   - `generate_session9_classes.rb`
   - `test_session9_autoload.rb`

## Critical Reminders

1. **Pattern 0 Compliance**: ALWAYS declare attributes BEFORE xml blocks
2. **Type Consistency**: Use `String` for all simple types
3. **Collections**: Use `collection: true` for arrays
4. **Cross-Namespace**: Use `String` type for cross-namespace references
5. **Namespace URI**: Use exact OpenXML namespace URI
6. **Testing**: Verify autoload after generation

## Expected Deliverables

1. ✅ `chart.yml` created (70 elements)
2. ✅ 70+ new classes generated
3. ✅ Autoload index created
4. ✅ All tests passing
5. ✅ Documentation updated
6. ✅ SESSION_10_SUMMARY.md created

## Success Criteria

- [ ] Chart namespace complete (70 elements)
- [ ] All classes generated without errors
- [ ] Autoload working correctly
- [ ] Pattern 0 compliance: 100%
- [ ] Zero syntax errors
- [ ] Progress: 80.5% overall (612/760 elements)

## Architecture Notes

### Chart Integration Strategy

Chart namespace is critical for:
1. **Data Visualization**: Bar, line, pie, scatter charts
2. **Business Reports**: Charts in Word documents
3. **Data Analysis**: Trendlines, error bars, statistics
4. **Presentation**: Professional chart formatting
5. **Excel Integration**: Charts linked to spreadsheet data

### Namespace Dependencies

```
Chart (c:) relies on:
- DrawingML (a:) - for chart visual elements
- SpreadsheetML (xls:) - for data source references
- Relationships (r:) - for external data links
```

### Key Design Decisions

1. **Chart Types**: Support 15 major chart types
2. **Series Model**: Flexible series with multiple data sources
3. **Axis System**: Category, value, date, and series axes
4. **Styling**: Separate shape and text properties
5. **Data Labels**: Rich customization options

## Phase 2 Progress Tracker

### Completed (612/760 = 80.5% after Session 10)
- ✅ Sessions 1-9: 542 elements
- 🎯 Session 10: Chart (70 elements)

### Remaining After Session 10 (148/760 = 19.5% remaining)
High priority:
- PresentationML (p:): 50 elements
- Custom XML (cxml:): 30 elements
- Bibliography (b:): 25 elements
- Remaining 12 namespaces: 43 elements

**Timeline**: 2-3 more sessions to complete Phase 2

## Performance Target

With velocity of 40+ elements/hour:
- Session 10: 70 elements → 4-5 hours
- Remaining: ~150 elements → 2-3 sessions
- Phase 2 completion: Day 6-7 (ahead of schedule!)

## Next Session Preview

### Session 11: PresentationML Namespace
- **Target**: ~50 elements (p: namespace)
- **Focus**: PowerPoint/presentation definitions
- **Expected Progress**: 80.5% → 87.1%

Good luck with Session 10! 🚀