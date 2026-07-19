# frozen_string_literal: true

module Uniword
  module Docx
    # An image part (word/media/*) held by the package: binary image
    # data plus the packaging metadata needed to emit it (relationship
    # target, relationship id, content type).
    #
    # The image content type is per-file (resolved from the file
    # extension), so it is always carried explicitly — the registry's
    # :image definition contributes only the relationship type.
    #
    # Replaces the raw +{ data:, target:, content_type:, path: }+ hash
    # entries formerly stored in +DocumentRoot#image_parts+. Hash-style
    # read access (+part[:data]+, +part[:target]+, +part[:content_type]+,
    # +part[:path]+) is kept for backward compatibility.
    #
    # @example
    #   part = ImagePart.new(
    #     r_id: "rId5", target: "media/image1.png",
    #     data: binary_data, content_type: "image/png",
    #   )
    #   part.data         # => binary image data
    #   part.content_type # => "image/png"
    class ImagePart < Part
      # @return [String, nil] path of the source file the image was
      #   read from (builder-added images only; nil for loaded parts)
      attr_accessor :source_path

      # @param r_id [String, nil] relationship id
      # @param target [String, nil] e.g. "media/image1.png"
      # @param data [String, nil] binary image data
      # @param content_type [String, nil] e.g. "image/png"
      # @param source_path [String, nil] on-disk source path
      # rubocop:disable Metrics/ParameterLists
      def initialize(r_id: nil, target: nil, data: nil, content_type: nil,
                     source_path: nil, **rest)
        super(
          definition: Ooxml::PartRegistry.find_by_key(:image),
          r_id: r_id, target: target, content: data,
          content_type: content_type, **rest
        )
        @source_path = source_path
      end
      # rubocop:enable Metrics/ParameterLists

      # Wrap a legacy raw-hash entry ({ data:, target:, content_type:,
      # path: }) into an ImagePart.
      #
      # @param hash [Hash] legacy hash entry
      # @return [ImagePart]
      def self.from_hash(hash)
        new(target: hash[:target], data: hash[:data],
            content_type: hash[:content_type], source_path: hash[:path])
      end

      # Binary image data (alias for content).
      #
      # @return [String, nil]
      def data
        content
      end

      # Set the binary image data (alias for content=).
      #
      # @param value [String, nil] binary image data
      # @return [void]
      def data=(value)
        self.content = value
      end

      # Hash-style read compatibility (+:data+ and the legacy +:path+
      # source path in addition to the Part keys).
      def [](key)
        case key.to_sym
        when :data then content
        when :path then source_path
        else super
        end
      end
    end
  end
end
