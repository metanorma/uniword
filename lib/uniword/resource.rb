# frozen_string_literal: true

module Uniword
  module Resource
    # SERVICES (stateless pure functions)
    autoload :ColorTransformer, "#{__dir__}/resource/color_transformer"
    autoload :FontSubstitutor, "#{__dir__}/resource/font_substitutor"

    # LOADERS (load resources from data files)
    autoload :ColorSchemeLoader, "#{__dir__}/resource/color_scheme_loader"
    autoload :FontSchemeLoader, "#{__dir__}/resource/font_scheme_loader"
    autoload :DocumentElementLoader,
             "#{__dir__}/resource/document_element_loader"
    autoload :ThemeMappingLoader, "#{__dir__}/resource/theme_mapping_loader"

    # TRANSITIONS (detect and migrate between theme systems)
    autoload :ThemeTransition, "#{__dir__}/resource/theme_transition"

    # MODELS (have state + behavior)
    autoload :ThemeProcessor, "#{__dir__}/resource/theme_processor"
    autoload :Cache, "#{__dir__}/resource/cache"
    autoload :CacheVersion, "#{__dir__}/resource/cache_version"
    autoload :ResourceResolver, "#{__dir__}/resource/resource_resolver"

    # VALUE OBJECTS (immutable structs)
    autoload :CachePaths, "#{__dir__}/resource/cache_paths"
    autoload :ResourceLocation, "#{__dir__}/resource/resource_location"

    # CONVERTERS (transform between formats)
    autoload :DocumentElementConverter,
             "#{__dir__}/resource/document_element_converter"

    # TEMPLATES
    autoload :DocumentElementTemplate,
             "#{__dir__}/resource/document_element_template"
  end
end
