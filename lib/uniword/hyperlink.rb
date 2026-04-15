# frozen_string_literal: true

require "lutaml/model"

module Uniword
  # Hyperlink convenience wrapper for external and internal links.
  #
  # This provides a simplified API over the underlying Wordprocessingml::Hyperlink model.
  #
  # @example External hyperlink
  #   link = Hyperlink.new(url: 'https://example.com', text: 'Click here')
  #   link.external?  # => true
  #   link.url        # => 'https://example.com'
  #
  # @example Internal hyperlink (bookmark)
  #   link = Hyperlink.new(anchor: 'section1', text: 'Go to section')
  #   link.internal?  # => true
  #   link.anchor    # => 'section1'
  class Hyperlink
    # @return [String, nil] URL for external links
    attr_reader :url

    # @return [String, nil] Anchor/bookmark name for internal links
    attr_reader :anchor

    # @return [String] Display text
    attr_reader :text

    # @return [String, nil] Tooltip text
    attr_reader :tooltip

    # @param url [String, nil] URL for external links
    # @param anchor [String, nil] Anchor for internal links
    # @param text [String] Display text
    # @param tooltip [String, nil] Optional tooltip
    def initialize(url: nil, anchor: nil, text: nil, tooltip: nil)
      @url = url
      @anchor = anchor
      @text = text
      @tooltip = tooltip
    end

    # @return [Boolean] True if this is an external URL link
    def external?
      !url.nil?
    end

    # @return [Boolean] True if this is an internal anchor link
    def internal?
      !anchor.nil?
    end

    # Convert to the underlying Wordprocessingml::Hyperlink model
    #
    # @return [Wordprocessingml::Hyperlink] The OOXML hyperlink element
    def to_model
      model = Wordprocessingml::Hyperlink.new
      model.id = url if url
      model.anchor = anchor if anchor
      model.tooltip = tooltip if tooltip

      if text
        run = Wordprocessingml::Run.new
        run.text = Wordprocessingml::Text.new(content: text)
        model.runs << run
      end

      model
    end

    # @return [Hash] Hash representation
    def to_h
      { url: url, anchor: anchor, text: text, tooltip: tooltip }
    end
  end
end
