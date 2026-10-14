# frozen_string_literal: true

require "nokogiri"
require "digest"

module Uniword
  module Builder
    # Builds chart elements for embedding in documents.
    #
    # Creates chart XML (ChartSpace) and the Drawing wrapper that
    # references it via relationship ID.
    #
    # Supports bar, line, and pie charts with literal data.
    #
    # @example Add a bar chart to a document
    #   doc.chart do |c|
    #     c.title 'Sales Report'
    #     c.categories ['Q1', 'Q2', 'Q3', 'Q4']
    #     c.series 'Revenue', data: [100, 200, 150, 300]
    #     c.series 'Costs', data: [80, 120, 100, 200]
    #   end
    #
    # @example Add a pie chart
    #   doc.chart(type: :pie) do |c|
    #     c.title 'Market Share'
    #     c.categories ['Product A', 'Product B', 'Product C']
    #     c.series 'Share', data: [45, 30, 25]
    #   end
    class ChartBuilder
      CHART_NS = "http://schemas.openxmlformats.org/drawingml/2006/chart"
      DRAWINGML_MAIN_NS =
        "http://schemas.openxmlformats.org/drawingml/2006/main"
      OFFICE_DOCUMENT_RELS_NS =
        "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
      CHART_REL_TYPE = Ooxml::PartRegistry.find_by_key(:chart).rel_type
      CHART_CONTENT_TYPE =
        Ooxml::PartRegistry.find_by_key(:chart).content_type

      attr_reader :chart_type, :title_text, :series_list, :show_legend, :width,
                  :height

      def initialize(chart_type: :bar)
        @chart_type = chart_type
        @title_text = nil
        @categories = []
        @series_list = []
        @show_legend = true
        @legend_position = "b"
        @width = 5_486_400  # default 6 inches in EMU
        @height = 3_200_400 # default ~3.5 inches in EMU
      end

      # Get or set category labels
      #
      # @param labels [Array<String>, nil] Category labels (setter if provided)
      # @return [Array<String>, self] Categories array (getter) or self (setter)
      def categories(labels = nil)
        if labels
          @categories = labels
          self
        else
          @categories
        end
      end

      def title(text)
        @title_text = text
        self
      end

      # Add a data series
      #
      # @param name [String] Series name
      # @param data [Array<Numeric>] Data values
      # @return [self]
      def series(name, data:)
        @series_list << { name: name, data: data }
        self
      end

      # Configure legend
      #
      # @param show [Boolean] Show legend (default true)
      # @param position [String] Position: 't', 'b', 'l', 'r', 'tr'
      # @return [self]
      def legend(show: true, position: "b")
        @show_legend = show
        @legend_position = position
        self
      end

      # Set chart dimensions
      #
      # @param width [Integer] Width in EMU (914400 = 1 inch)
      # @param height [Integer] Height in EMU
      # @return [self]
      def dimensions(width:, height:)
        @width = width
        @height = height
        self
      end

      # Build the chart XML string
      #
      # @return [String] Chart XML
      def build_xml
        @document = Moxml.new.create_document
        @document.add_child(@document.create_declaration("1.0", "UTF-8"))
        root = @document.create_element("c:chartSpace")
        root.add_namespace("c", CHART_NS)
        root.add_namespace("a", DRAWINGML_MAIN_NS)
        root.add_namespace("r", OFFICE_DOCUMENT_RELS_NS)
        @document.root = root
        build_chart(root)
        @document.to_xml
      end

      # Register chart on a document and create the Drawing element
      #
      # The relationship id comes from the document's IdAllocator
      # (single authority), so the c:chart reference and the assembled
      # document relationship always agree.
      #
      # @param document [DocumentBuilder, DocumentRoot] Target document
      # @return [Wordprocessingml::Drawing]
      def build_drawing(document)
        root = document.is_a?(Uniword::Builder::DocumentBuilder) ? document.model : document
        create_drawing(register_chart_part(root))
      end

      private

      # Store the chart XML as a chart part keyed by its allocated rId.
      #
      # @param root [Wordprocessingml::DocumentRoot] target document
      # @return [String] relationship id of the chart part
      def register_chart_part(root)
        root.allocator ||= Docx::IdAllocator.new

        target = "charts/chart#{root.chart_parts.size + 1}.xml"
        r_id = root.allocator.alloc_rid(target: target, type: CHART_REL_TYPE)

        root.chart_parts[r_id] = Docx::ChartPart.new(
          r_id: r_id, target: target, content: build_xml,
        )
        r_id
      end

      include DeterministicId

      # Build the inner chart XML
      def build_chart(parent)
        chart = add_element(parent, "c:chart")
        if @title_text
          title = add_element(chart, "c:title")
          tx = add_element(title, "c:tx")
          rich = add_element(tx, "c:rich")
          add_element(rich, "a:bodyPr")
          add_element(rich, "a:lstStyle")
          p_el = add_element(rich, "a:p")
          r_el = add_element(p_el, "a:r")
          add_text(add_element(r_el, "a:t"), @title_text)
          add_element(title, "c:overlay", "val" => "0")
        end

        add_element(chart, "c:autoTitleDeleted", "val" => "0")

        plot_area = add_element(chart, "c:plotArea")
        build_chart_type(plot_area)

        unless @chart_type == :pie
          build_axis(plot_area, "catAx", "10", "b", "20")
          build_axis(plot_area, "valAx", "20", "l", "10")
        end

        if @show_legend
          legend = add_element(chart, "c:legend")
          add_element(legend, "c:legendPos", "val" => @legend_position)
          add_element(legend, "c:overlay", "val" => "0")
        end

        add_element(chart, "c:plotVisOnly", "val" => "1")
        chart
      end

      # Build the specific chart type element
      def build_chart_type(parent)
        case @chart_type
        when :bar
          chart = add_element(parent, "c:barChart")
          add_element(chart, "c:barDir", "val" => "col")
          add_element(chart, "c:grouping", "val" => "clustered")
          add_element(chart, "c:varyColors", "val" => "0")
          build_all_series(chart)
          add_element(chart, "c:axId", "val" => "10")
          add_element(chart, "c:axId", "val" => "20")
        when :line
          chart = add_element(parent, "c:lineChart")
          add_element(chart, "c:grouping", "val" => "standard")
          add_element(chart, "c:varyColors", "val" => "0")
          build_all_series(chart)
          add_element(chart, "c:axId", "val" => "10")
          add_element(chart, "c:axId", "val" => "20")
        when :pie
          chart = add_element(parent, "c:pieChart")
          add_element(chart, "c:varyColors", "val" => "1")
          build_all_series(chart)
        end
      end

      # Build all series XML blocks
      def build_all_series(parent)
        @series_list.each_with_index do |s, i|
          build_series(parent, s, i)
        end
      end

      # Build a single series XML block
      def build_series(parent, series, index)
        ser = add_element(parent, "c:ser")
        add_element(ser, "c:idx", "val" => index)
        add_element(ser, "c:order", "val" => index)
        tx = add_element(ser, "c:tx")
        str_ref = add_element(tx, "c:strRef")
        add_text(add_element(str_ref, "c:f"), "Sheet1!$B$#{index + 1}")
        str_cache = add_element(str_ref, "c:strCache")
        add_element(str_cache, "c:ptCount", "val" => 1)
        pt = add_element(str_cache, "c:pt", "idx" => 0)
        add_text(add_element(pt, "c:v"), series[:name])
        build_categories(ser)
        build_values(ser, series[:data])
        ser
      end

      # Build category data XML
      def build_categories(parent)
        return if @categories.empty?

        cat = add_element(parent, "c:cat")
        str_ref = add_element(cat, "c:strRef")
        add_text(add_element(str_ref, "c:f"), "Sheet1!$A$2:$A$100")
        str_cache = add_element(str_ref, "c:strCache")
        add_element(str_cache, "c:ptCount", "val" => @categories.size)
        @categories.each_with_index do |category, idx|
          pt = add_element(str_cache, "c:pt", "idx" => idx)
          add_text(add_element(pt, "c:v"), category)
        end
      end

      # Build values data XML
      def build_values(parent, data)
        val = add_element(parent, "c:val")
        num_ref = add_element(val, "c:numRef")
        add_text(add_element(num_ref, "c:f"), "Sheet1!$C$2:$C$100")
        num_cache = add_element(num_ref, "c:numCache")
        add_text(add_element(num_cache, "c:formatCode"), "General")
        add_element(num_cache, "c:ptCount", "val" => data.size)
        data.each_with_index do |value, idx|
          pt = add_element(num_cache, "c:pt", "idx" => idx)
          add_text(add_element(pt, "c:v"), value.to_s)
        end
      end

      # Build a chart axis
      def build_axis(parent, tag, id, position, cross_id)
        case tag
        when "catAx"
          write_axis_content(add_element(parent, "c:catAx"), id, position,
                             cross_id)
        when "valAx"
          write_axis_content(add_element(parent, "c:valAx"), id, position,
                             cross_id)
        when "serAx"
          write_axis_content(add_element(parent, "c:serAx"), id, position,
                             cross_id)
        else
          raise ArgumentError, "Unknown axis type: #{tag}"
        end
      end

      def write_axis_content(axis, id, position, cross_id)
        add_element(axis, "c:axId", "val" => id)
        scaling = add_element(axis, "c:scaling")
        add_element(scaling, "c:orientation", "val" => "minMax")
        add_element(axis, "c:delete", "val" => "0")
        add_element(axis, "c:axPos", "val" => position)
        add_element(axis, "c:majorGridlines")
        add_element(axis, "c:numFmt", "formatCode" => "General",
                                      "sourceLinked" => "1")
        add_element(axis, "c:tickLblPos", "val" => "nextTo")
        add_element(axis, "c:crossAx", "val" => cross_id)
      end

      # Append an element with attributes to a parent node.
      def add_element(parent, name, attributes = {})
        element = @document.create_element(name)
        attributes.each { |key, value| element[key] = value }
        parent.add_child(element)
        element
      end

      # Append a text node to a parent node.
      def add_text(parent, content)
        parent.add_child(@document.create_text(content))
      end

      # Create a Drawing element with chart reference
      def create_drawing(r_id)
        drawing = Wordprocessingml::Drawing.new

        inline = WpDrawing::Inline.new
        inline.extent = WpDrawing::Extent.new(cx: @width, cy: @height)
        inline.effect_extent = WpDrawing::EffectExtent.new
        inline.doc_properties = WpDrawing::DocProperties.new(
          id: deterministic_id("chart", @chart_type, r_id),
          name: "Chart #{@chart_type}",
        )

        graphic = Drawingml::Graphic.new
        graphic.graphic_data = Drawingml::GraphicData.new
        graphic.graphic_data.uri = CHART_NS
        graphic.graphic_data.chart = Chart::ChartReference.new(id: r_id)

        inline.graphic = graphic
        drawing.inline = inline
        drawing
      end
    end
  end
end
