# frozen_string_literal: true

module Uniword
  module Builder
    # Builds watermark elements for documents.
    #
    # Watermarks in OOXML are implemented as VML shapes placed in the header.
    # The shape uses a textpath for the watermark text with semi-transparent fill.
    #
    # @example Add a text watermark
    #   doc.watermark('CONFIDENTIAL')
    #
    # @example Custom watermark
    #   doc.watermark('DRAFT', font: 'Arial', size: 80, color: 'FF0000',
    #                 opacity: '0.3', angle: 45)
    #
    # @example Remove watermark (set empty header)
    #   doc.watermark(nil)
    class WatermarkBuilder
      # Build a watermark VML shape
      #
      # @param text [String] Watermark text
      # @param font [String] Font name (default 'Calibri')
      # @param size [Integer] Font size in points (default 60)
      # @param color [String] Fill color hex (default 'lightgray' → 'D0D0D0')
      # @param opacity [String] Opacity value '0.0' to '1.0' (default '0.3')
      # @param angle [Integer] Rotation angle in degrees (default -45)
      # @return [Vml::Shape] The watermark shape
      def self.build_shape(text, font: "Calibri", size: 60, color: nil,
                           opacity: "0.3", angle: -45)
        fill_color = color || "D0D0D0"

        shape = Vml::Shape.new(
          id: "PowerPlusWaterMarkObject1",
          type: "#_x0000_t136",
          style: watermark_style(angle),
          fillcolor: fill_color,
          strokecolor: "none",
        )

        shape.fill = Vml::Fill.new(
          type: "tile",
          opacity: opacity,
          color: fill_color,
        )

        shape.textpath = Vml::TextPath.new(
          string: text,
          style: "font-family:'#{font}';font-size:#{size}pt",
        )

        shape
      end

      # Build a watermark paragraph containing the VML shape
      #
      # @param text [String] Watermark text
      # @param font [String] Font name
      # @param size [Integer] Font size in points
      # @param color [String] Fill color hex
      # @param opacity [String] Opacity value
      # @param angle [Integer] Rotation angle in degrees
      # @return [Wordprocessingml::Paragraph] Paragraph containing watermark
      def self.build_paragraph(text, font: "Calibri", size: 60, color: nil,
                               opacity: "0.3", angle: -45)
        para = Wordprocessingml::Paragraph.new
        run = Wordprocessingml::Run.new
        run.pictures << Wordprocessingml::Picture.new(
          shape: build_shape(text, font: font, size: size,
                                   color: color, opacity: opacity, angle: angle),
        )
        para.runs << run
        para
      end

      class << self
        private

        # Generate the VML style attribute for the watermark shape
        #
        # @param angle [Integer] Rotation angle in degrees
        # @return [String] CSS-style style attribute
        def watermark_style(angle)
          # Position centered on the page (in points/twips)
          "position:absolute;margin-left:0;margin-top:0;width:527.85pt;" \
            "height:698.45pt;rotation:#{angle};z-index:-251657216;" \
            "mso-position-horizontal:center;" \
            "mso-position-horizontal-relative:margin;" \
            "mso-position-vertical:center;" \
            "mso-position-vertical-relative:margin"
        end
      end
    end
  end
end
