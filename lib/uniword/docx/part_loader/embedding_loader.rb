# frozen_string_literal: true

module Uniword
  module Docx
    class PartLoader
      # Loads OLE/embedded object binaries (word/embeddings/*) into
      # the package's embeddings collection, keyed by relationship
      # target (path relative to word/).
      class EmbeddingLoader
        # @param context [LoadContext] shared load state
        # @param definition [Ooxml::PartDefinition] :ole_object
        # @return [void]
        def load(context, definition)
          paths = context.matching_paths(definition)
          return if paths.empty?

          embeddings = context.package.embeddings
          paths.each do |path|
            embeddings[path.delete_prefix("word/")] =
              context.zip_content[path]
          end
        end
      end
    end
  end
end
