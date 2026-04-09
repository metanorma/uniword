# frozen_string_literal: true

module Uniword
  module Styles
    autoload :StyleDefinition, "#{__dir__}/styles/style_definition"
    autoload :ParagraphStyleDefinition, "#{__dir__}/styles/paragraph_style_definition"
    autoload :CharacterStyleDefinition, "#{__dir__}/styles/character_style_definition"
    autoload :TableStyleDefinition, "#{__dir__}/styles/table_style_definition"
    autoload :ListStyleDefinition, "#{__dir__}/styles/list_style_definition"
    autoload :SemanticStyle, "#{__dir__}/styles/semantic_style"
    autoload :StyleLibrary, "#{__dir__}/styles/style_library"
  end
end
