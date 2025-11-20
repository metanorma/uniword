# frozen_string_literal: true

require 'base64'
require_relative 'lazy_loader'

module Uniword
  # Represents an image (inline element)
  # Responsibility: Hold image reference and metadata
  #
  # An image is an inline element that references an external image file.
  # It contains metadata about the image such as dimensions and relationship ID.
  #
  # Uses lazy loading to defer loading of actual image data until needed,
  # which improves memory efficiency for documents with many images.
  class Image < Element
    extend LazyLoader
    # OOXML namespace configuration for images (drawing elements)
    xml do
      root 'drawing', mixed: true
      namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'
      namespace 'http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing', 'wp'
      namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'
      namespace 'http://schemas.openxmlformats.org/drawingml/2006/picture', 'pic'
      namespace 'http://schemas.openxmlformats.org/officeDocument/2006/relationships', 'r'
    end

    # Image relationship ID (reference to the image file in the package)
    attribute :relationship_id, :string

    # Image width (in EMUs - English Metric Units)
    attribute :width, :integer

    # Image height (in EMUs - English Metric Units)
    attribute :height, :integer

    # Alternative text for accessibility
    attribute :alt_text, :string

    # Image title/description
    attribute :title, :string

    # Image filename/path (for reference)
    attribute :filename, :string

    # Positioning attributes
    # Whether image is inline with text (default: true)
    attribute :inline, :boolean, default: -> { true }

    # Horizontal alignment (:left, :center, :right)
    attribute :horizontal_alignment, :string

    # Vertical alignment (:top, :middle, :bottom)
    attribute :vertical_alignment, :string

    # Text wrapping style (:square, :tight, :through, :none, etc.)
    attribute :text_wrapping, :string

    # Image data loader (proc that loads the actual binary data)
    # This is not serialized - it's used for lazy loading
    attr_accessor :data_loader

    # Cached image data (lazy loaded)
    attr_reader :cached_data

    # Load image data lazily
    #
    # @return [String, nil] The binary image data
    def image_data
      return @cached_data if defined?(@cached_data)

      @cached_data = @data_loader&.call
    end

    # Check if image data is loaded
    #
    # @return [Boolean] true if image data is cached
    def image_data_loaded?
      defined?(@cached_data)
    end

    # Clear cached image data to free memory
    #
    # @return [void]
    def clear_image_data
      remove_instance_variable(:@cached_data) if defined?(@cached_data)
    end

    # Set image data (for manual assignment)
    #
    # @param data [String] The binary image data
    # @return [String] The data
    def image_data=(data)
      @cached_data = data
    end

    # Get image size without loading full data
    #
    # @return [Integer, nil] The size in bytes if data is loaded
    def image_size
      return nil unless image_data_loaded?

      @cached_data&.bytesize
    end

    # Set floating mode (not inline)
    #
    # @return [Boolean] true
    def floating=(value)
      self.inline = !value
    end

    # Check if image is floating (not inline)
    #
    # @return [Boolean] true if floating
    def floating
      !inline
    end

    # Accept a visitor for the visitor pattern
    #
    # @param visitor [Object] The visitor object
    # @return [Object] The result of the visit operation
    def accept(visitor)
      visitor.visit_image(self)
    end

    # Get text content (images have no text)
    # Compatible with Run API for text extraction
    #
    # @return [String] Empty string (images don't have text)
    def text
      ""
    end

    # Get properties (images don't have RunProperties)
    # Compatible with Run API for serialization
    #
    # @return [nil] Always returns nil (images don't have RunProperties)
    def properties
      nil
    end

    # Get width in points (converted from EMUs)
    # 1 point = 12700 EMUs
    #
    # @return [Float, nil] Width in points
    def width_in_points
      return nil unless width

      width / 12_700.0
    end

    # Get height in points (converted from EMUs)
    # 1 point = 12700 EMUs
    #
    # @return [Float, nil] Height in points
    def height_in_points
      return nil unless height

      height / 12_700.0
    end

    # Get width in pixels (assuming 96 DPI)
    # 1 pixel = 9525 EMUs at 96 DPI
    #
    # @return [Integer, nil] Width in pixels
    def width_in_pixels
      return nil unless width

      (width / 9525.0).round
    end

    # Get height in pixels (assuming 96 DPI)
    # 1 pixel = 9525 EMUs at 96 DPI
    #
    # @return [Integer, nil] Height in pixels
    def height_in_pixels
      return nil unless height

      (height / 9525.0).round
    end

    # Get aspect ratio
    #
    # @return [Float, nil] Aspect ratio (width/height)
    def aspect_ratio
      return nil unless width && height&.positive?

      width.to_f / height
    end

    # Create image from base64 encoded data
    #
    # @param base64_data [String] Base64 encoded image data
    # @param width [Integer, nil] Width in EMUs
    # @param height [Integer, nil] Height in EMUs
    # @param alt_text [String, nil] Alternative text
    # @param title [String, nil] Image title
    # @return [Image] New image instance
    def self.from_base64(base64_data, width: nil, height: nil, alt_text: nil, title: nil)
      binary_data = Base64.decode64(base64_data)
      from_data(binary_data, width: width, height: height, alt_text: alt_text, title: title)
    end

    # Create image from binary data
    #
    # @param binary_data [String] Binary image data
    # @param width [Integer, nil] Width in EMUs
    # @param height [Integer, nil] Height in EMUs
    # @param alt_text [String, nil] Alternative text
    # @param title [String, nil] Image title
    # @return [Image] New image instance
    def self.from_data(binary_data, width: nil, height: nil, alt_text: nil, title: nil)
      image = new(
        width: width,
        height: height,
        alt_text: alt_text,
        title: title,
        relationship_id: 'temp_' + SecureRandom.hex(8)
      )
      image.image_data = binary_data
      image
    end

    # Alias for image_data for API compatibility
    # Get binary image data
    #
    # @return [String, nil] The binary image data
    def data
      image_data
    end

    # Save image data to a file
    # Convenient method to save image data to disk
    #
    # @param path [String] The file path to save to
    # @return [Integer] Number of bytes written
    # @raise [RuntimeError] if no image data is available
    def save(path)
      data_to_save = image_data
      raise 'No image data available to save' unless data_to_save

      File.binwrite(path, data_to_save)
    end

    protected

    # Validate that required attributes are present
    #
    # @return [Boolean] true if relationship_id is present
    def required_attributes_valid?
      !relationship_id.nil? && !relationship_id.empty?
    end
  end
end
