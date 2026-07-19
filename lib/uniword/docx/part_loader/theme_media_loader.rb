# frozen_string_literal: true

module Uniword
  module Docx
    class PartLoader
      # Loads theme media files (word/theme/media/*) into the parsed
      # theme's media_files. Runs only when a theme part was loaded —
      # theme media without a theme is ignored, as before.
      class ThemeMediaLoader
        # @param context [LoadContext] shared load state
        # @param definition [Ooxml::PartDefinition] :theme_media
        # @return [void]
        def load(context, definition)
          theme = context.package.theme
          return unless theme

          media = extract_media(context, definition)
          theme.media_files = media if media.any?
        end

        private

        # @return [Hash] filename => Themes::MediaFile
        def extract_media(context, definition)
          prefix = definition.pattern_prefix
          paths = context.matching_paths(definition)
          paths.each_with_object({}) do |path, media|
            filename = path.delete_prefix(prefix)
            media[filename] = Uniword::Themes::MediaFile.new(
              filename: filename,
              content: context.zip_content[path],
              source_path: path,
            )
          end
        end
      end
    end
  end
end
