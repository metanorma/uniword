# frozen_string_literal: true

module Uniword
  module Resource
    # SERVICES (stateless pure functions)
    autoload :ColorTransformer, "#{__dir__}/resource/color_transformer"
    autoload :FontSubstitutor, "#{__dir__}/resource/font_substitutor"

    # MODELS (have state + behavior)
    autoload :ThemeProcessor, "#{__dir__}/resource/theme_processor"
    autoload :Cache, "#{__dir__}/resource/cache"
    autoload :CacheVersion, "#{__dir__}/resource/cache_version"
    autoload :ResourceResolver, "#{__dir__}/resource/resource_resolver"

    # VALUE OBJECTS (immutable structs)
    autoload :CachePaths, "#{__dir__}/resource/cache_paths"
    autoload :ResourceLocation, "#{__dir__}/resource/resource_location"
  end
end
