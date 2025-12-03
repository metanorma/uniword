#!/usr/bin/env ruby
# frozen_string_literal: true

# Fix chart schema by replacing undefined types with String

require 'yaml'

schema_file = 'config/ooxml/schemas/chart.yml'
schema = YAML.load_file(schema_file)

# List of 70 defined element class names
defined_types = %w[
  ChartSpace Chart Title AutoTitleDeleted PlotArea
  BarChart Bar3DChart LineChart Line3DChart PieChart Pie3DChart
  AreaChart Area3DChart ScatterChart RadarChart SurfaceChart Surface3DChart
  DoughnutChart BubbleChart StockChart
  Series Index Order SeriesText CategoryAxisData Values XValues YValues
  BubbleSize NumberReference
  CatAx ValAx DateAx SerAx AxisId Scaling Orientation AxisPosition
  MajorGridlines MinorGridlines NumberingFormat TickLabelPosition
  Legend LegendPosition LegendEntry DataLabels DataLabel
  ShowLegendKey ShowValue ShowCategoryName
  ShapeProperties TextProperties Style ColorMapOverride Marker MarkerStyle
  MarkerSize Smooth Explosion GapWidth
  Trendline TrendlineType ErrorBars ErrorDirection ErrorBarType
  UpDownBars HiLowLines DropLines Layout PlotVisOnly
  String Integer
]

changes = []

schema['elements'].each do |element_name, element_def|
  next unless element_def['attributes']

  element_def['attributes'].each do |attr|
    type = attr['type']
    next if %w[String Integer].include?(type)
    next if defined_types.include?(type)

    # This type is not defined - change to String
    changes << "#{element_name}.#{attr['name']}: #{type} → String"
    attr['type'] = 'String'
  end
end

File.write(schema_file, YAML.dump(schema))

puts "Fixed #{changes.size} undefined types:"
changes.each { |c| puts "  • #{c}" }
