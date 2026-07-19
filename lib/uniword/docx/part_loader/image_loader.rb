# frozen_string_literal: true

module Uniword
  module Docx
    class PartLoader
      # Loads image parts (word/media/*) into the document's
      # image_parts hash, keyed by the relationship id the loaded
      # document rels assign to each media target so downstream
      # consumers (MHTML rendering, image manager) resolve r:embed
      # references correctly. Media with no document-level rel (e.g.
      # theme-only images) gets a synthetic key; it never becomes a
      # relationship.
      #
      # The content type is derived from the file extension; the
      # extension mapping is wider than the registry's Default entries
      # (bmp, tiff, svg) and preserved verbatim from the historic
      # load path.
      class ImageLoader
        # Extension → content type mapping (wider than the registry's
        # Default entries; preserved verbatim from the historic load
        # path).
        CONTENT_TYPES = {
          "jpg" => "image/jpeg", "jpeg" => "image/jpeg",
          "png" => "image/png", "gif" => "image/gif",
          "bmp" => "image/bmp",
          "tiff" => "image/tiff", "tif" => "image/tiff",
          "svg" => "image/svg+xml"
        }.freeze

        # @param context [LoadContext] shared load state
        # @param definition [Ooxml::PartDefinition] :image
        # @return [void]
        def load(context, definition)
          package = context.package
          return unless package.document

          paths = context.matching_paths(definition)
          return if paths.empty?

          package.document.image_parts ||= {}
          paths.each do |path|
            load_image(context, definition, path)
          end
        end

        private

        def load_image(context, definition, path)
          package = context.package
          filename = File.basename(path)
          r_id = loaded_image_rid(package, definition, filename) ||
            next_synthetic_image_key(package)

          package.document.image_parts[r_id] = {
            data: binary_data(context, path),
            target: "media/#{filename}",
            content_type: content_type_for(filename),
          }
        end

        # The rId a loaded document relationship assigns to
        # "media/<filename>", or nil when no image rel targets it.
        def loaded_image_rid(package, definition, filename)
          rel = package.document_rels&.relationships&.find do |r|
            r.target == "media/#{filename}" &&
              r.type.to_s == definition.rel_type
          end
          rel&.id
        end

        # Synthetic image-part key that cannot collide with a loaded
        # relationship id or an already-keyed image part.
        def next_synthetic_image_key(package)
          taken = package.document_rels&.relationships&.map(&:id) || []
          n = package.document.image_parts.size + 1
          n += 1 while taken.include?("rId#{n}")
          "rId#{n}"
        end

        # Re-read bytes from the original ZIP when available (the
        # extracted hash may carry corrupted UTF-8 binary).
        def binary_data(context, path)
          return context.zip_content[path] unless context.zip_path

          read_binary_from_zip(context.zip_path, path)
        end

        def read_binary_from_zip(zip_path, entry_path)
          require "zip"
          Zip::File.open(zip_path) do |zip_file|
            entry = zip_file.find_entry(entry_path)
            return nil unless entry

            entry.get_input_stream.read
          end
        end

        def content_type_for(filename)
          ext = File.extname(filename).delete(".").downcase
          CONTENT_TYPES.fetch(ext, "image/#{ext}")
        end
      end
    end
  end
end
