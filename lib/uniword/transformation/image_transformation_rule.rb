# frozen_string_literal: true


module Uniword
  module Transformation
    # Transformation rule for Image elements.
    #
    # Responsibility: Transform Image objects between DOCX and MHTML formats.
    # Single Responsibility - handles only Image transformations.
    #
    # Transforms image properties including positioning, dimensions, and metadata.
    #
    # @example Transform DOCX image to MHTML
    #   rule = ImageTransformationRule.new(source_format: :docx, target_format: :mhtml)
    #   mhtml_image = rule.transform(docx_image)
    class ImageTransformationRule < TransformationRule
      # Check if this rule matches the transformation request
      #
      # @param element_type [Class] The element class
      # @param source_format [Symbol] Source format
      # @param target_format [Symbol] Target format
      # @return [Boolean] true if matches
      def matches?(element_type:, source_format:, target_format:)
        element_type == Image &&
          source_format == @source_format &&
          target_format == @target_format
      end

      # Transform an image from source format to target format
      #
      # Creates new Image with adapted properties.
      #
      # @param source_image [Image] Source image
      # @return [Image] Transformed image
      # @raise [ArgumentError] if source_image is not an Image
      def transform(source_image)
        validate_element_type(source_image, Image)

        # Create new image with core properties
        target_image = Image.new(
          relationship_id: source_image.relationship_id,
          width: source_image.width,
          height: source_image.height,
          filename: source_image.filename,
          alt_text: source_image.alt_text,
          title: source_image.title
        )

        # Transform positioning properties
        transform_positioning(source_image, target_image)

        target_image
      end

      private

      # Transform image positioning properties
      #
      # @param source [Image] Source image
      # @param target [Image] Target image
      def transform_positioning(source, target)
        # Copy positioning properties (same across formats)
        target.inline = source.inline
        target.horizontal_alignment = source.horizontal_alignment
        target.vertical_alignment = source.vertical_alignment
        target.text_wrapping = source.text_wrapping
      end
    end
  end
end
