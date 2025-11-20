# frozen_string_literal: true

module Uniword
  # Represents a bookmark or anchor in a document.
  #
  # Responsibility: Store bookmark metadata for creating internal links
  # and anchors within a document. Bookmarks allow users to navigate
  # to specific locations within a document.
  #
  # A bookmark consists of:
  # - A name that uniquely identifies it
  # - An optional target element reference
  #
  # @example Create a bookmark
  #   bookmark = Uniword::Bookmark.new(
  #     name: 'section1',
  #     target_element: paragraph
  #   )
  #
  # @example Access bookmark properties
  #   bookmark.name           # => 'section1'
  #   bookmark.target_element # => paragraph
  class Bookmark
    # @return [String] The unique name/identifier for this bookmark
    attr_accessor :name

    # @return [Element, nil] The target element this bookmark references
    attr_accessor :target_element

    # @return [String, nil] The OOXML bookmark ID for round-trip preservation
    attr_accessor :bookmark_id

    # Initialize a new Bookmark.
    #
    # @param name [String] The unique bookmark name
    # @param target_element [Element, nil] The element this bookmark references
    # @param bookmark_id [String, nil] The OOXML bookmark ID
    #
    # @example Create a bookmark
    #   bookmark = Bookmark.new(name: 'intro')
    #
    # @example Create a bookmark with target
    #   bookmark = Bookmark.new(name: 'intro', target_element: paragraph)
    #
    # @example Create a bookmark with OOXML ID for round-trip
    #   bookmark = Bookmark.new(name: 'intro', bookmark_id: '1')
    def initialize(name:, target_element: nil, bookmark_id: nil)
      @name = name
      @target_element = target_element
      @bookmark_id = bookmark_id
    end

    # Check if bookmark has a target element.
    #
    # @return [Boolean] true if bookmark has a target element
    def target?
      !@target_element.nil?
    end

    # Generate HTML anchor name.
    #
    # Sanitizes the bookmark name for use in HTML anchors.
    #
    # @return [String] The sanitized anchor name
    #
    # @example Get anchor name
    #   bookmark = Bookmark.new(name: 'My Section!')
    #   bookmark.anchor_name # => "my_section"
    def anchor_name
      @name.to_s.downcase.gsub(/[^a-z0-9_-]/, '_')
    end

    # Convert to hash representation.
    #
    # @return [Hash] Hash representation of the bookmark
    def to_h
      {
        name: @name,
        target_element: @target_element,
        bookmark_id: @bookmark_id
      }
    end

    # Check equality with another bookmark.
    #
    # @param other [Bookmark] The other bookmark to compare
    # @return [Boolean] true if bookmarks have the same name
    def ==(other)
      return false unless other.is_a?(Bookmark)

      @name == other.name
    end

    alias eql? ==

    # Generate hash code for bookmark.
    #
    # @return [Integer] Hash code based on name
    def hash
      @name.hash
    end

    # Get the text content of this bookmark
    # Returns empty string as bookmarks themselves don't contain text,
    # but this method is needed for API compatibility with other text elements
    #
    # @return [String] Empty string (bookmarks don't contain direct text)
    def text
      ""
    end

    # Set the text content of this bookmark
    # This is a no-op for bookmarks as they don't contain direct text,
    # but this method is needed for API compatibility with other text elements
    #
    # @param value [String] The text to set (ignored for bookmarks)
    # @return [String] The value that was passed in
    def text=(value)
      # Bookmarks don't contain text content directly
      # This method exists for API compatibility only
      value
    end

    # Get the properties of this bookmark
    # Returns nil as bookmarks don't have formatting properties,
    # but this method is needed for API compatibility with Run objects
    #
    # @return [nil] Always returns nil (bookmarks don't have properties)
    def properties
      nil
    end
  end
end