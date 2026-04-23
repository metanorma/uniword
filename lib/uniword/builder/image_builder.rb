# frozen_string_literal: true

require "securerandom"
require "stringio"

module Uniword
  module Builder
    # Builds images as Drawing elements for embedding in documents.
    #
    # Supports both inline (flowing with text) and anchor (floating/positioned)
    # images, with proper OOXML Picture chain:
    #   Drawing → Inline/Anchor → Graphic → GraphicData → Picture
    #     → NonVisualPictureProperties
    #     → PictureBlipFill → Blip
    #     → PictureShapeProperties → Transform2D
    #
    # @example Add an inline image to a paragraph
    #   para << Builder.image('photo.png', width: 500_000, height: 300_000)
    #
    # @example Add a floating image
    #   para << Builder.image('logo.png', width: 200_000, height: 200_000,
    #                         floating: true, align: :right)
    #
    # @example Add an image via RunBuilder
    #   run = RunBuilder.new.drawing(ImageBuilder.create_drawing('photo.png'))
    class ImageBuilder
      # Picture namespace URI for GraphicData
      PIC_URI = "http://schemas.openxmlformats.org/drawingml/2006/picture"

      # Register an image part on the document for DOCX packaging.
      #
      # @param document [DocumentBuilder, DocumentRoot] Target document
      # @param path [String] Path to image file
      # @return [String] Relationship ID (e.g., 'rIdImg1')
      def self.register_image(document, path)
        root = document.respond_to?(:model) ? document.model : document
        if root
          root.image_parts ||= {}
          r_id = "rIdImg#{root.image_parts.size + 1}"
        else
          # No document context — generate a placeholder rId
          r_id = "rIdImg#{SecureRandom.random_number(1_000_000)}"
        end

        content_type = case File.extname(path).downcase
                       when ".png"  then "image/png"
                       when ".jpg", ".jpeg" then "image/jpeg"
                       when ".gif"  then "image/gif"
                       when ".bmp"  then "image/bmp"
                       when ".tiff", ".tif" then "image/tiff"
                       when ".svg" then "image/svg+xml"
                       else "application/octet-stream"
                       end

        if root
          root.image_parts[r_id] = {
            path: path,
            data: File.binread(path),
            content_type: content_type,
            target: "media/#{File.basename(path)}",
          }
        end
        r_id
      end

      # Read image dimensions from file (PNG/JPEG/GIF)
      #
      # @param path [String] Path to image file
      # @return [Array(Integer, Integer)] [width, height] in pixels
      def self.read_dimensions(path)
        data = File.binread(path)[0..64]

        if data&.start_with?("\x89PNG".b)
          # PNG: width at offset 16, height at offset 20 (big-endian uint32)
          w = data[16, 4].unpack1("N")
          h = data[20, 4].unpack1("N")
          [w, h]
        elsif data&.start_with?("\xFF\xD8".b)
          # JPEG: parse SOF marker
          io = StringIO.new(File.binread(path))
          io.read(2) # SOI
          loop do
            marker = io.read(2)
            break unless marker&.start_with?("\xFF".b)

            length = io.read(2)&.unpack1("n")
            break unless length

            payload = io.read(length - 2)
            byte1 = marker.bytes[1]
            # SOF0, SOF2, SOF3 markers contain dimensions
            next unless byte1.between?(0xC0, 0xC3) ||
              byte1 == 0xC5 || byte1 == 0xC6 ||
              byte1 == 0xC7 || byte1.between?(0xC9, 0xCB) ||
              byte1 == 0xCD || byte1 == 0xCE || byte1 == 0xCF

            h = payload[0, 2].unpack1("n")
            w = payload[2, 2].unpack1("n")
            return [w, h]
          end
          [100, 100] # fallback
        else
          [100, 100] # fallback for unknown formats
        end
      rescue StandardError
        [100, 100] # fallback
      end

      # Create an inline Drawing from an image file
      #
      # Builds the full OOXML Picture chain:
      #   Drawing > Inline > Graphic > GraphicData > Picture
      #     > nvPicPr > cNvPr + cNvPicPr
      #     > blipFill > blip(r:embed) + stretch > fillRect
      #     > spPr > xfrm(off+ext) + prstGeom
      #
      # @param document [DocumentBuilder, DocumentRoot] Target document
      # @param path [String] Path to image file
      # @param width [Integer, nil] Width in EMU (914400 EMU = 1 inch)
      # @param height [Integer, nil] Height in EMU
      # @param alt_text [String, nil] Alternative text
      # @return [Wordprocessingml::Drawing]
      def self.create_drawing(document, path, width: nil, height: nil,
alt_text: nil)
        r_id = register_image(document, path)

        px_w, px_h = read_dimensions(path)
        w = width || (px_w * 9525) # pixels to EMU
        h = height || (px_h * 9525)

        drawing = Wordprocessingml::Drawing.new

        inline = WpDrawing::Inline.new
        inline.extent = WpDrawing::Extent.new(cx: w, cy: h)
        inline.effect_extent = WpDrawing::EffectExtent.new
        inline.doc_properties = WpDrawing::DocProperties.new(
          id: SecureRandom.random_number(1_000_000_000),
          name: File.basename(path, ".*"),
        )
        inline.graphic = build_graphic(r_id, w, h)

        drawing.inline = inline
        drawing
      end

      # Create a floating (anchored) Drawing from an image file
      #
      # @param document [DocumentBuilder, DocumentRoot] Target document
      # @param path [String] Path to image file
      # @param width [Integer, nil] Width in EMU
      # @param height [Integer, nil] Height in EMU
      # @param alt_text [String, nil] Alternative text
      # @param align [Symbol, nil] Horizontal alignment (:left, :center, :right)
      # @param vertical_align [Symbol, nil] Vertical alignment (:top, :middle, :bottom)
      # @param wrap [Symbol] Text wrapping (:square, :none, :top_and_bottom, default :square)
      # @param behind_text [Boolean] Place image behind text (default false)
      # @param pos_x [Integer, nil] Horizontal position offset in EMU
      # @param pos_y [Integer, nil] Vertical position offset in EMU
      # @return [Wordprocessingml::Drawing]
      def self.create_floating(document, path, width: nil, height: nil, alt_text: nil,
                               align: nil, vertical_align: nil, wrap: :square,
                               behind_text: false, pos_x: nil, pos_y: nil)
        r_id = register_image(document, path)

        px_w, px_h = read_dimensions(path)
        w = width || (px_w * 9525)
        h = height || (px_h * 9525)

        drawing = Wordprocessingml::Drawing.new

        anchor = WpDrawing::Anchor.new
        anchor.simple_pos = WpDrawing::SimplePos.new(x: 0, y: 0)
        anchor.relative_height = 251_658_240
        anchor.behind_doc = behind_text ? "1" : "0"
        anchor.locked = "0"
        anchor.layout_in_cell = "1"
        anchor.allow_overlap = "1"

        # Horizontal positioning
        anchor.position_h = WpDrawing::PositionH.new(
          relative_from: "margin",
        )
        if align
          anchor.position_h.align = align.to_s
        elsif pos_x
          anchor.position_h.pos_offset = pos_x
        else
          anchor.position_h.align = "left"
        end

        # Vertical positioning
        anchor.position_v = WpDrawing::PositionV.new(
          relative_from: "margin",
        )
        if vertical_align
          anchor.position_v.align = vertical_align.to_s
        elsif pos_y
          anchor.position_v.pos_offset = pos_y
        else
          anchor.position_v.align = "top"
        end

        anchor.extent = WpDrawing::Extent.new(cx: w, cy: h)
        anchor.effect_extent = WpDrawing::EffectExtent.new

        # Text wrapping
        case wrap
        when :none
          anchor.wrap_none = WpDrawing::WrapNone.new
        when :square
          anchor.wrap_square = WpDrawing::WrapSquare.new(wrap_text: "bothSides")
        when :top_and_bottom
          anchor.wrap_top_and_bottom = WpDrawing::WrapTopAndBottom.new
        end

        anchor.doc_properties = WpDrawing::DocProperties.new(
          id: SecureRandom.random_number(1_000_000_000),
          name: File.basename(path, ".*"),
        )
        anchor.graphic = build_graphic(r_id, w, h)

        drawing.anchor = anchor
        drawing
      end

      # Create a Run containing an inline image Drawing
      #
      # @param document [DocumentBuilder, DocumentRoot] Target document
      # @param path [String] Path to image file
      # @param width [Integer, nil] Width in EMU
      # @param height [Integer, nil] Height in EMU
      # @param alt_text [String, nil] Alternative text
      # @return [Wordprocessingml::Run]
      def self.create_run(document, path, width: nil, height: nil,
alt_text: nil)
        run = Wordprocessingml::Run.new
        run.drawings << create_drawing(document, path,
                                       width: width, height: height,
                                       alt_text: alt_text)
        run
      end

      # Create a Run containing a floating image Drawing
      #
      # @param document [DocumentBuilder, DocumentRoot] Target document
      # @param path [String] Path to image file
      # @param width [Integer, nil] Width in EMU
      # @param height [Integer, nil] Height in EMU
      # @param alt_text [String, nil] Alternative text
      # @param align [Symbol, nil] Horizontal alignment
      # @param wrap [Symbol] Text wrapping style
      # @param behind_text [Boolean] Place behind text
      # @return [Wordprocessingml::Run]
      def self.create_floating_run(document, path, width: nil, height: nil,
                                   alt_text: nil, align: nil, wrap: :square,
                                   behind_text: false)
        run = Wordprocessingml::Run.new
        run.drawings << create_floating(document, path,
                                        width: width, height: height,
                                        alt_text: alt_text, align: align,
                                        wrap: wrap, behind_text: behind_text)
        run
      end

      class << self
        private

        # Build the Graphic > GraphicData > Picture chain
        #
        # @param r_id [String] Relationship ID for the image
        # @param width [Integer] Width in EMU
        # @param height [Integer] Height in EMU
        # @return [Drawingml::Graphic]
        def build_graphic(r_id, width, height)
          graphic_data = Drawingml::GraphicData.new(uri: PIC_URI)
          graphic_data.picture = build_picture(r_id, width, height)

          graphic = Drawingml::Graphic.new
          graphic.graphic_data = graphic_data
          graphic
        end

        # Build the Picture::Picture element
        #
        # @param r_id [String] Relationship ID for the image
        # @param width [Integer] Width in EMU
        # @param height [Integer] Height in EMU
        # @return [Picture::Picture]
        def build_picture(r_id, width, height)
          pic = Picture::Picture.new

          # Non-visual properties
          pic.nv_pic_pr = Picture::NonVisualPictureProperties.new
          pic.nv_pic_pr.c_nv_pr = Drawingml::NonVisualDrawingProperties.new(
            id: SecureRandom.random_number(1_000_000_000),
            name: "Picture #{SecureRandom.random_number(1_000_000)}",
          )
          pic.nv_pic_pr.c_nv_pic_pr = Picture::NonVisualPictureDrawingProperties.new

          # Blip fill (image reference)
          pic.blip_fill = Picture::PictureBlipFill.new
          pic.blip_fill.blip = Drawingml::Blip.new(embed: r_id)
          pic.blip_fill.stretch = Picture::PictureStretch.new
          pic.blip_fill.stretch.fill_rect = Picture::FillRect.new

          # Shape properties (transform + geometry)
          pic.sp_pr = Picture::PictureShapeProperties.new
          pic.sp_pr.xfrm = Drawingml::Transform2D.new
          pic.sp_pr.xfrm.off = Drawingml::Offset.new(x: 0, y: 0)
          pic.sp_pr.xfrm.ext = Drawingml::Extents.new(cx: width, cy: height)
          pic.sp_pr.prst_geom = Drawingml::PresetGeometry.new(prst: "rect")

          pic
        end
      end
    end
  end
end
