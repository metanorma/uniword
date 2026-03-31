# frozen_string_literal: true

# Chart Namespace Autoload Index
# Generated for Uniword v2.0 - Session 10
# Namespace: http://schemas.openxmlformats.org/drawingml/2006/chart
# Prefix: c
# Elements: 70

module Uniword
  module Chart
    # Chart Container (5 elements)
    autoload :ChartSpace, "#{__dir__}/chart/chart_space"
    autoload :Chart, "#{__dir__}/chart/chart"
    autoload :ChartReference, "#{__dir__}/chart/chart_reference"
    autoload :DiagramReference, "#{__dir__}/chart/diagram_reference"
    autoload :Title, "#{__dir__}/chart/title"
    autoload :AutoTitleDeleted, "#{__dir__}/chart/auto_title_deleted"
    autoload :PlotArea, "#{__dir__}/chart/plot_area"

    # Chart Types (15 elements)
    autoload :BarChart, "#{__dir__}/chart/bar_chart"
    autoload :Bar3DChart, "#{__dir__}/chart/bar3_d_chart"
    autoload :LineChart, "#{__dir__}/chart/line_chart"
    autoload :Line3DChart, "#{__dir__}/chart/line3_d_chart"
    autoload :PieChart, "#{__dir__}/chart/pie_chart"
    autoload :Pie3DChart, "#{__dir__}/chart/pie3_d_chart"
    autoload :AreaChart, "#{__dir__}/chart/area_chart"
    autoload :Area3DChart, "#{__dir__}/chart/area3_d_chart"
    autoload :ScatterChart, "#{__dir__}/chart/scatter_chart"
    autoload :RadarChart, "#{__dir__}/chart/radar_chart"
    autoload :SurfaceChart, "#{__dir__}/chart/surface_chart"
    autoload :Surface3DChart, "#{__dir__}/chart/surface3_d_chart"
    autoload :DoughnutChart, "#{__dir__}/chart/doughnut_chart"
    autoload :BubbleChart, "#{__dir__}/chart/bubble_chart"
    autoload :StockChart, "#{__dir__}/chart/stock_chart"

    # Series & Data (10 elements)
    autoload :Series, "#{__dir__}/chart/series"
    autoload :Index, "#{__dir__}/chart/index"
    autoload :Order, "#{__dir__}/chart/order"
    autoload :SeriesText, "#{__dir__}/chart/series_text"
    autoload :CategoryAxisData, "#{__dir__}/chart/category_axis_data"
    autoload :Values, "#{__dir__}/chart/values"
    autoload :XValues, "#{__dir__}/chart/x_values"
    autoload :YValues, "#{__dir__}/chart/y_values"
    autoload :BubbleSize, "#{__dir__}/chart/bubble_size"
    autoload :NumberReference, "#{__dir__}/chart/number_reference"

    # Axes (12 elements)
    autoload :CatAx, "#{__dir__}/chart/cat_ax"
    autoload :ValAx, "#{__dir__}/chart/val_ax"
    autoload :DateAx, "#{__dir__}/chart/date_ax"
    autoload :SerAx, "#{__dir__}/chart/ser_ax"
    autoload :AxisId, "#{__dir__}/chart/axis_id"
    autoload :Scaling, "#{__dir__}/chart/scaling"
    autoload :Orientation, "#{__dir__}/chart/orientation"
    autoload :AxisPosition, "#{__dir__}/chart/axis_position"
    autoload :MajorGridlines, "#{__dir__}/chart/major_gridlines"
    autoload :MinorGridlines, "#{__dir__}/chart/minor_gridlines"
    autoload :NumberingFormat, "#{__dir__}/chart/numbering_format"
    autoload :TickLabelPosition, "#{__dir__}/chart/tick_label_position"

    # Legend & Labels (8 elements)
    autoload :Legend, "#{__dir__}/chart/legend"
    autoload :LegendPosition, "#{__dir__}/chart/legend_position"
    autoload :LegendEntry, "#{__dir__}/chart/legend_entry"
    autoload :DataLabels, "#{__dir__}/chart/data_labels"
    autoload :DataLabel, "#{__dir__}/chart/data_label"
    autoload :ShowLegendKey, "#{__dir__}/chart/show_legend_key"
    autoload :ShowValue, "#{__dir__}/chart/show_value"
    autoload :ShowCategoryName, "#{__dir__}/chart/show_category_name"

    # Styling & Formatting (10 elements)
    autoload :ShapeProperties, "#{__dir__}/chart/shape_properties"
    autoload :TextProperties, "#{__dir__}/chart/text_properties"
    autoload :Style, "#{__dir__}/chart/style"
    autoload :ColorMapOverride, "#{__dir__}/chart/color_map_override"
    autoload :Marker, "#{__dir__}/chart/marker"
    autoload :MarkerStyle, "#{__dir__}/chart/marker_style"
    autoload :MarkerSize, "#{__dir__}/chart/marker_size"
    autoload :Smooth, "#{__dir__}/chart/smooth"
    autoload :Explosion, "#{__dir__}/chart/explosion"
    autoload :GapWidth, "#{__dir__}/chart/gap_width"

    # Advanced Features (10 elements)
    autoload :Trendline, "#{__dir__}/chart/trendline"
    autoload :TrendlineType, "#{__dir__}/chart/trendline_type"
    autoload :ErrorBars, "#{__dir__}/chart/error_bars"
    autoload :ErrorDirection, "#{__dir__}/chart/error_direction"
    autoload :ErrorBarType, "#{__dir__}/chart/error_bar_type"
    autoload :UpDownBars, "#{__dir__}/chart/up_down_bars"
    autoload :HiLowLines, "#{__dir__}/chart/hi_low_lines"
    autoload :DropLines, "#{__dir__}/chart/drop_lines"
    autoload :Layout, "#{__dir__}/chart/layout"
    autoload :PlotVisOnly, "#{__dir__}/chart/plot_vis_only"

    # Factory method for creating a new ChartSpace
    #
    # @param options [Hash] Chart configuration options
    # @return [ChartSpace] A new chart space instance
    def self.new(_options = {})
      ChartSpace.new
    end
  end
end
