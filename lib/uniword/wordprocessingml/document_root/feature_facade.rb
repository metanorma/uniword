# frozen_string_literal: true

module Uniword
  module Wordprocessingml
    class DocumentRoot < Lutaml::Model::Serializable
      # Facade methods for CLI Vision features.
      #
      # Provides convenience methods on DocumentRoot that delegate to
      # specialized Manager classes. Each manager is lazily initialized
      # and cached for the lifetime of the document.
      #
      # Query methods return data; mutator methods return +self+ for
      # method chaining:
      #
      #   doc.add_comment(text: "Fix this", author: "Alice")
      #       .add_watermark("DRAFT")
      #       .insert_toc
      #       .save("output.docx")
      #
      module FeatureFacade
        # --- Review (comments & tracked changes) ---

        # List all comments in the document.
        #
        # @return [Array<Uniword::Comment>]
        def list_comments
          review_manager.list_comments
        end

        # Add a comment to the document.
        #
        # @param text [String] Comment text
        # @param author [String] Author name
        # @param initials [String, nil] Author initials
        # @return [self]
        def add_comment(text:, author:, initials: nil)
          review_manager.add_comment(text: text, author: author,
                                     initials: initials)
          self
        end

        # Accept all tracked changes in the document.
        #
        # @return [self]
        def accept_all_changes
          review_manager.accept_all
          self
        end

        # Reject all tracked changes in the document.
        #
        # @return [self]
        def reject_all_changes
          review_manager.reject_all
          self
        end

        # Remove all comments from the document.
        #
        # @return [self]
        def clear_comments
          review_manager.clear_comments
          self
        end

        # --- Diff ---

        # Compare this document with another and return the differences.
        #
        # @param other_doc [DocumentRoot] The document to compare against
        # @param text_only [Boolean] Skip formatting comparison
        # @return [Uniword::Diff::DiffResult]
        def diff(other_doc, text_only: false)
          opts = {}
          opts[:text_only] = true if text_only
          Uniword::Diff::DocumentDiffer.new(self, other_doc,
                                            options: opts).diff
        end

        # --- Spellcheck ---

        # Run spell and grammar checks on the document.
        #
        # @param language [String] Dictionary language (default: "en_US")
        # @return [Uniword::Spellcheck::SpellcheckResult]
        def spellcheck(language: "en_US")
          Uniword::Spellcheck::SpellChecker.new(language: language)
                                           .check(self)
        end

        # --- Images ---

        # List all images in the document with metadata.
        #
        # @return [Array<Uniword::Images::ImageInfo>]
        def list_images
          image_manager.list
        end

        # Extract all images to a directory on disk.
        #
        # @param output_dir [String] Target directory
        # @return [Integer] Number of images extracted
        def extract_images(output_dir)
          image_manager.extract(output_dir)
        end

        # Insert an image into the document.
        #
        # @param image_path [String] Path to the image file
        # @param options [Hash] See Images::ImageManager#insert
        # @return [self]
        def insert_image(image_path, **options)
          image_manager.insert(image_path, **options)
          self
        end

        # Remove an image from the document by filename.
        #
        # @param image_name [String] Filename (e.g., "image1.png")
        # @return [self]
        def remove_image(image_name)
          image_manager.remove(image_name)
          self
        end

        # --- Watermark ---

        # Add a text watermark to the document.
        #
        # @param text [String] Watermark text
        # @param color [String] Hex color (e.g., "#808080")
        # @param font_size [Integer] Font size in points
        # @param font [String] Font family name
        # @param opacity [String] Opacity value (e.g., ".5")
        # @return [self]
        def add_watermark(text, color: "#808080", font_size: 72,
                          font: "Segoe UI", opacity: ".5")
          watermark_manager.add(text, color: color, font_size: font_size,
                                      font: font, opacity: opacity)
          self
        end

        # Remove all watermarks from the document.
        #
        # @return [self]
        def remove_watermark
          watermark_manager.remove
          self
        end

        # Check if the document has any watermarks.
        #
        # @return [Boolean]
        def watermark?
          watermark_manager.present?
        end

        # List all watermark texts in the document.
        #
        # @return [Array<String>]
        def list_watermarks
          watermark_manager.list
        end

        # --- Table of Contents ---

        # Generate TOC entries from heading paragraphs.
        #
        # @param max_level [Integer] Maximum heading level (1-6)
        # @return [Array<Uniword::Toc::TocEntry>]
        def generate_toc(max_level: 6)
          toc_generator.generate(max_level: max_level)
        end

        # Generate and insert a TOC into the document.
        #
        # @param position [Integer] Insert position (0 = beginning)
        # @param max_level [Integer] Maximum heading level (1-6)
        # @return [self]
        def insert_toc(position: 0, max_level: 6)
          entries = toc_generator.generate(max_level: max_level)
          toc_generator.insert(entries, position: position,
                                        max_level: max_level)
          self
        end

        # Update an existing TOC in the document.
        #
        # @param max_level [Integer] Maximum heading level (1-6)
        # @return [self]
        def update_toc(max_level: 6)
          toc_generator.update(max_level: max_level)
          self
        end

        # --- Headers & Footers ---

        # List headers with metadata (type, text, emptiness).
        #
        # @return [Array<Hash>]
        def list_headers
          headers_footers_manager.list_headers
        end

        # List footers with metadata (type, text, emptiness).
        #
        # @return [Array<Hash>]
        def list_footers
          headers_footers_manager.list_footers
        end

        # Add a header to the document.
        #
        # @param text [String] Header text content
        # @param type [String] Header type (default/first/even)
        # @return [self]
        def add_header(text, type: "default")
          headers_footers_manager.add_header(text, type: type)
          self
        end

        # Add a footer to the document.
        #
        # @param text [String] Footer text content
        # @param type [String] Footer type (default/first/even)
        # @return [self]
        def add_footer(text, type: "default")
          headers_footers_manager.add_footer(text, type: type)
          self
        end

        # Remove headers by type.
        #
        # @param type [String] Header type (default/first/even)
        # @return [self]
        def remove_headers(type:)
          headers_footers_manager.remove_headers(type: type)
          self
        end

        # Remove footers by type.
        #
        # @param type [String] Footer type (default/first/even)
        # @return [self]
        def remove_footers(type:)
          headers_footers_manager.remove_footers(type: type)
          self
        end

        # --- Protection ---

        # Apply editing restriction to the document.
        #
        # @param protection_type [Symbol] One of :read_only, :comments,
        #   :tracked_changes, :forms
        # @param password [String, nil] Optional password
        # @return [self]
        def protect(protection_type, password: nil)
          protection_manager.apply(protection_type, password: password)
          self
        end

        # Remove all protection from the document.
        #
        # @return [self]
        def unprotect
          protection_manager.remove
          self
        end

        # Check if the document has protection applied.
        #
        # @return [Boolean]
        def protection_active?
          protection_manager.protected?
        end

        # Get current protection info.
        #
        # @return [Hash, nil]
        def protection_info
          protection_manager.info
        end

        private

        # Lazy-initialized managers (cached per document instance)

        def review_manager
          @review_manager ||= Uniword::Review::ReviewManager.new(self)
        end

        def image_manager
          @image_manager ||= Uniword::Images::ImageManager.new(self)
        end

        def watermark_manager
          @watermark_manager ||= Uniword::Watermark::Manager.new(self)
        end

        def toc_generator
          @toc_generator ||= Uniword::Toc::TocGenerator.new(self)
        end

        def headers_footers_manager
          @headers_footers_manager ||=
            Uniword::HeadersFooters::Manager.new(self)
        end

        def protection_manager
          @protection_manager ||= Uniword::Protect::Manager.new(self)
        end
      end
    end
  end
end
