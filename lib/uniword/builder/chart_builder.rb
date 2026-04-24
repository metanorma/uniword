# frozen_string_literal: true

require "nokogiri"
require "securerandom"

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
      CHART_REL_TYPE =
        "http://schemas.openxmlformats.org/officeDocument/2006/relationships/chart"
      CHART_CONTENT_TYPE =
        "application/vnd.openxmlformats-officedocument." \
        "drawingml.chart+xml"

      attr_reader :chart_type, :title_text, :series_list

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

      # Set chart title
      #
      # @param text [String] Title text
      # @return [self]
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
        builder = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
          xml["c"].chartSpace("xmlns:c" => CHART_NS,
                              "xmlns:a" =>
                                "http://schemas.openxmlformats.org/drawingml/2006/main",
                              "xmlns:r" =>
                                "http://schemas.openxmlformats.org/officeDocument/2006/relationships") do
            build_chart_xml(xml)
          end
        end
        builder.to_xml
      end

      # Register chart on a document and create the Drawing element
      #
      # @param document [DocumentBuilder, DocumentRoot] Target document
      # @return [Wordprocessingml::Drawing]
      def build_drawing(document)
        root = document.respond_to?(:model) ? document.model : document
        root.chart_parts ||= {}

        r_id = "rIdChart#{root.chart_parts.size + 1}"
        target = "charts/chart#{root.chart_parts.size + 1}.xml"

        root.chart_parts[r_id] = {
          xml: build_xml,
          target: target,
        }

        create_drawing(r_id)
      end

      private

      # Build the inner chart XML
      def build_chart_xml(xml)
        xml["c"].chart do
          # Title
          if @title_text
            xml["c"].title do
              xml["c"].tx do
                xml["c"].rich do
                  xml["a"].bodyPr
                  xml["a"].lstStyle
                  xml["a"].p do
                    xml["a"].r do
                      xml["a"].t(@title_text)
                    end
                  end
                end
              end
              xml["c"].overlay("val" => "0")
            end
          end

          xml["c"].autoTitleDeleted("val" => "0")

          # Plot area
          xml["c"].plotArea do
            build_chart_type(xml)

            # Category axis (for bar/line, not pie)
            unless @chart_type == :pie
              xml["c"].catAx do
                xml["c"].axId("val" => "10")
                xml["c"].scaling do
                  xml["c"].orientation("val" => "minMax")
                end
                xml["c"].delete("val" => "0")
                xml["c"].axPos("val" => "b")
                xml["c"].majorGridlines
                xml["c"].numFmt("formatCode" => "General",
                                "sourceLinked" => "1")
                xml["c"].tickLblPos("val" => "nextTo")
                xml["c"].crossAx("val" => "20")
              end

              # Value axis
              xml["c"].valAx do
                xml["c"].axId("val" => "20")
                xml["c"].scaling do
                  xml["c"].orientation("val" => "minMax")
                end
                xml["c"].delete("val" => "0")
                xml["c"].axPos("val" => "l")
                xml["c"].majorGridlines
                xml["c"].numFmt("formatCode" => "General",
                                "sourceLinked" => "1")
                xml["c"].tickLblPos("val" => "nextTo")
                xml["c"].crossAx("val" => "10")
              end
            end
          end

          # Legend
          if @show_legend
            xml["c"].legend do
              xml["c"].legendPos("val" => @legend_position)
              xml["c"].overlay("val" => "0")
            end
          end

          xml["c"].plotVisOnly("val" => "1")
        end
      end

      # Build the specific chart type element (bar, line, pie)
      def build_chart_type(xml)
        case @chart_type
        when :bar
          build_bar_chart(xml)
        when :line
          build_line_chart(xml)
        when :pie
          build_pie_chart(xml)
        end
      end

      # Build bar chart XML
      def build_bar_chart(xml)
        xml["c"].barChart do
          xml["c"].barDir("val" => "col")
          xml["c"].grouping("val" => "clustered")
          xml["c"].varyColors("val" => "0")

          @series_list.each_with_index do |s, i|
            xml["c"].ser do
              xml["c"].idx("val" => i)
              xml["c"].order("val" => i)
              xml["c"].tx do
                xml["c"].strRef do
                  xml["c"].f("Sheet1!$B$#{i + 1}")
                  xml["c"].strCache do
                    xml["c"].ptCount("val" => 1)
                    xml["c"].pt("idx" => 0) { xml["c"].v(s[:name]) }
                  end
                end
              end
              build_categories(xml)
              build_values(xml, s[:data])
            end
          end

          xml["c"].axId("val" => "10")
          xml["c"].axId("val" => "20")
        end
      end

      # Build line chart XML
      def build_line_chart(xml)
        xml["c"].lineChart do
          xml["c"].grouping("val" => "standard")
          xml["c"].varyColors("val" => "0")

          @series_list.each_with_index do |s, i|
            xml["c"].ser do
              xml["c"].idx("val" => i)
              xml["c"].order("val" => i)
              xml["c"].tx do
                xml["c"].strRef do
                  xml["c"].f("Sheet1!$B$#{i + 1}")
                  xml["c"].strCache do
                    xml["c"].ptCount("val" => 1)
                    xml["c"].pt("idx" => 0) { xml["c"].v(s[:name]) }
                  end
                end
              end
              build_categories(xml)
              build_values(xml, s[:data])
            end
          end

          xml["c"].axId("val" => "10")
          xml["c"].axId("val" => "20")
        end
      end

      # Build pie chart XML
      def build_pie_chart(xml)
        xml["c"].pieChart do
          xml["c"].varyColors("val" => "1")

          @series_list.each_with_index do |s, i|
            xml["c"].ser do
              xml["c"].idx("val" => i)
              xml["c"].order("val" => i)
              xml["c"].tx do
                xml["c"].strRef do
                  xml["c"].f("Sheet1!$B$#{i + 1}")
                  xml["c"].strCache do
                    xml["c"].ptCount("val" => 1)
                    xml["c"].pt("idx" => 0) { xml["c"].v(s[:name]) }
                  end
                end
              end
              build_categories(xml)
              build_values(xml, s[:data])
            end
          end
        end
      end

      # Build category data XML
      def build_categories(xml)
        return if @categories.empty?

        xml["c"].cat do
          xml["c"].strRef do
            xml["c"].f("Sheet1!$A$2:$A$100")
            xml["c"].strCache do
              xml["c"].ptCount("val" => @categories.size)
              @categories.each_with_index do |cat, idx|
                xml["c"].pt("idx" => idx) { xml["c"].v(cat) }
              end
            end
          end
        end
      end

      # Build values data XML
      def build_values(xml, data)
        xml["c"].val do
          xml["c"].numRef do
            xml["c"].f("Sheet1!$C$2:$C$100")
            xml["c"].numCache do
              xml["c"].formatCode("General")
              xml["c"].ptCount("val" => data.size)
              data.each_with_index do |val, idx|
                xml["c"].pt("idx" => idx) { xml["c"].v(val.to_s) }
              end
            end
          end
        end
      end

      # Create a Drawing element with chart reference
      def create_drawing(r_id)
        drawing = Wordprocessingml::Drawing.new

        inline = WpDrawing::Inline.new
        inline.extent = WpDrawing::Extent.new(cx: @width, cy: @height)
        inline.effect_extent = WpDrawing::EffectExtent.new
        inline.doc_properties = WpDrawing::DocProperties.new(
          id: SecureRandom.random_number(1_000_000_000),
          name: "Chart #{SecureRandom.random_number(1_000_000)}",
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
