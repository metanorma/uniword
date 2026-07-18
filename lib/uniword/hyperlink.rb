# frozen_string_literal: true

module Uniword
  # Hyperlink convenience wrapper for external and internal links.
  #
  # Converts to Wordprocessingml::Hyperlink model objects. For external
  # links, properly assigns an rId that references a relationship in
  # document.xml.rels — not the raw URL string.
  #
  # @example External hyperlink
  #   link = Hyperlink.new(url: 'https://example.com', text: 'Click here')
  #   link.external?  # => true
  #
  # @example Internal hyperlink (bookmark)
  #   link = Hyperlink.new(anchor: 'section1', text: 'Go to section')
  #   link.internal?  # => true
  class Hyperlink
    REL_TYPE = Ooxml::PartRegistry.find_by_key(:hyperlink).rel_type

    attr_reader :url, :anchor, :text, :tooltip

    def initialize(url: nil, anchor: nil, text: nil, tooltip: nil)
      @url = url
      @anchor = anchor
      @text = text
      @tooltip = tooltip
    end

    def external?
      !url.nil?
    end

    def internal?
      !anchor.nil?
    end

    # Convert to the underlying Wordprocessingml::Hyperlink model.
    #
    # When an allocator is provided, external links get a proper rId
    # registered as a hyperlink relationship. Without an allocator,
    # falls back to setting id to the raw URL (legacy behavior).
    #
    # @param allocator [Docx::IdAllocator, nil] ID allocator for rId assignment
    # @return [Wordprocessingml::Hyperlink] The OOXML hyperlink element
    def to_model(allocator: nil)
      model = Wordprocessingml::Hyperlink.new

      if url
        if allocator
          r_id = allocator.alloc_rid(
            target: url,
            type: REL_TYPE,
            target_mode: "External",
          )
          model.id = r_id
        else
          model.id = url
        end
      end

      model.anchor = anchor if anchor
      model.tooltip = tooltip if tooltip

      if text
        run = Wordprocessingml::Run.new
        run.text = Wordprocessingml::Text.cast(text)
        model.runs << run
      end

      model
    end

    def to_h
      { url: url, anchor: anchor, text: text, tooltip: tooltip }
    end
  end
end
