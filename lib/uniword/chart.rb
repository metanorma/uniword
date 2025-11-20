# frozen_string_literal: true

module Uniword
  # Represents a chart element in a Word document
  #
  # Responsibility: Model chart data and metadata for serialization/deserialization
  # Single Responsibility: Only represents chart structure, not serialization logic
  #
  # Charts in OOXML are stored in separate XML files (word/charts/chart1.xml, etc.)
  # and referenced from the main document through relationships. This class represents
  # the chart object that bridges the document and the chart part.
  #
  # Architecture:
  # - Chart metadata stored in this model
  # - Chart XML content stored in chart part file
  # - Relationship links document to chart part
  # - Schema-driven serialization handles XML generation
  #
  # @example Create a simple chart
  #   chart = Chart.new(
  #     chart_type: 'bar',
  #     title: 'Sales by Quarter',
  #     relationship_id: 'rId5'
  #   )
  #
  # @example Access chart properties
  #   chart.chart_type  # => 'bar'
  #   chart.title       # => 'Sales by Quarter'
  #   chart.series.count # => 4
  class Chart < Element
    # @return [String] Type of chart (bar, line, pie, scatter, etc.)
    attribute :chart_type, :string

    # @return [String, nil] Chart title
    attribute :title, :string

    # @return [String] Relationship ID linking to chart part
    attribute :relationship_id, :string

    # @return [String, nil] Chart part path (e.g., 'charts/chart1.xml')
    attribute :part_path, :string

    # @return [Hash, nil] Raw chart data (for deserialization)
    attribute :chart_data, :hash

    # Chart series data (stored as plain Ruby array)
    attr_accessor :series

    # Chart axes data (stored as plain Ruby array)
    attr_accessor :axes

    # @return [Hash, nil] Legend configuration
    attribute :legend, :hash

    # @return [Hash, nil] Plot area configuration
    attribute :plot_area, :hash

    # @return [Boolean] Whether to vary colors by point
    attribute :vary_colors, :boolean, default: -> { false }

    # Initialize a new Chart
    #
    # @param attributes [Hash] Chart attributes
    # @option attributes [String] :chart_type Chart type
    # @option attributes [String] :title Chart title
    # @option attributes [String] :relationship_id Relationship ID
    # @option attributes [String] :part_path Chart part path
    # @option attributes [Hash] :chart_data Raw chart data
    # @option attributes [Array<Hash>] :series Series data
    # @option attributes [Array<Hash>] :axes Axes data
    # @option attributes [Hash] :legend Legend configuration
    # @option attributes [Hash] :plot_area Plot area configuration
    # @option attributes [Boolean] :vary_colors Vary colors flag
    def initialize(attributes = {})
      # Initialize arrays before calling super
      @series = attributes.delete(:series) || []
      @axes = attributes.delete(:axes) || []
      super
    end

    # Visitor pattern support
    #
    # @param visitor [Object] The visitor object
    # @return [Object] Result of visit operation
    def accept(visitor)
      visitor.visit_chart(self) if visitor.respond_to?(:visit_chart)
    end

    # Validate chart
    #
    # @return [Boolean] true if valid
    def valid?
      return false if relationship_id.nil? || relationship_id.empty?
      return false if chart_type.nil? || chart_type.empty?

      true
    end

    # Get chart type category
    #
    # @return [Symbol] Chart category (:bar, :line, :pie, :scatter, :area, :other)
    def category
      case chart_type.to_s.downcase
      when /bar/
        :bar
      when /line/
        :line
      when /pie|doughnut/
        :pie
      when /scatter|xy/
        :scatter
      when /area/
        :area
      when /radar/
        :radar
      when /stock/
        :stock
      when /bubble/
        :bubble
      when /surface/
        :surface
      else
        :other
      end
    end

    # Check if chart has data
    #
    # @return [Boolean] true if chart has series data
    def has_data?
      !series.empty?
    end

    # Get number of series
    #
    # @return [Integer] Number of data series
    def series_count
      series.length
    end

    # Get number of data points in first series
    #
    # @return [Integer, nil] Number of points, or nil if no series
    def point_count
      return nil if series.empty?

      first_series = series.first
      return nil unless first_series.is_a?(Hash)

      values = first_series[:values] || first_series['values']
      return nil if values.nil?

      values.length
    end

    # Check if chart has a title
    #
    # @return [Boolean] true if chart has title
    def has_title?
      !title.nil? && !title.empty?
    end

    # Check if chart has legend
    #
    # @return [Boolean] true if chart has legend
    def has_legend?
      !legend.nil? && !legend.empty?
    end

    # Get legend position
    #
    # @return [String, nil] Legend position (b, l, r, t, tr)
    def legend_position
      return nil unless legend.is_a?(Hash)

      legend[:position] || legend['position']
    end

    # Add a data series
    #
    # @param series_data [Hash] Series data
    # @option series_data [String] :name Series name
    # @option series_data [Array] :values Data values
    # @option series_data [Array] :categories Category labels
    # @return [void]
    def add_series(series_data)
      @series ||= []
      @series << series_data
    end

    # Add an axis
    #
    # @param axis_data [Hash] Axis data
    # @option axis_data [String] :type Axis type (cat, val, date, ser)
    # @option axis_data [String] :position Axis position (b, l, r, t)
    # @option axis_data [Integer] :id Axis ID
    # @return [void]
    def add_axis(axis_data)
      @axes ||= []
      @axes << axis_data
    end

    # Convert to hash representation
    #
    # @return [Hash] Hash with chart data
    def to_h
      {
        chart_type: chart_type,
        title: title,
        relationship_id: relationship_id,
        part_path: part_path,
        series_count: series_count,
        has_legend: has_legend?,
        legend_position: legend_position,
        category: category
      }.compact
    end

    # String representation
    #
    # @return [String] Human-readable description
    def to_s
      title_str = has_title? ? " '#{title}'" : ''
      "Chart(#{chart_type}#{title_str}, #{series_count} series)"
    end

    # Detailed inspection
    #
    # @return [String] Detailed description
    def inspect
      "#<#{self.class} " \
        "@chart_type=#{chart_type.inspect} " \
        "@title=#{title.inspect} " \
        "@relationship_id=#{relationship_id.inspect} " \
        "@series_count=#{series_count} " \
        "@has_legend=#{has_legend?}>"
    end

    protected

    # Validate required attributes
    #
    # @return [Boolean] true if required attributes present
    def required_attributes_valid?
      !relationship_id.nil? && !chart_type.nil?
    end
  end
end