# frozen_string_literal: true

module Uniword
  module Resource
    # Value object for cache directory paths
    # Immutable - create new instance if paths change
    CachePaths = Struct.new(:base, :themes, :stylesets, :color_schemes, :font_schemes,
                            :version_file) do
      # Factory method - creates from WordImplementation
      def self.from_word_implementation(word_impl)
        base = word_impl.cache_path
        new(
          base: base,
          themes: File.join(base, "themes"),
          stylesets: File.join(base, "stylesets"),
          color_schemes: File.join(base, "color_schemes"),
          font_schemes: File.join(base, "font_schemes"),
          version_file: File.join(base, "version.json")
        )
      end

      def ensure_directories_exist!
        [base, themes, stylesets, color_schemes, font_schemes].each do |dir|
          FileUtils.mkdir_p(dir) unless File.directory?(dir)
        end
      end
    end
  end
end
