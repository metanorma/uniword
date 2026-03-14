# frozen_string_literal: true

module Uniword
  module Styles
    # Style builder and definition classes
    autoload :StyleBuilder, 'uniword/wordprocessingml/styles/style_builder'
    autoload :StyleDefinition, 'uniword/wordprocessingml/styles/style_definition'
    autoload :StyleLibrary, 'uniword/wordprocessingml/styles/style_library'
    autoload :CharacterStyleDefinition, 'uniword/wordprocessingml/styles/character_style_definition'
    autoload :ParagraphStyleDefinition, 'uniword/wordprocessingml/styles/paragraph_style_definition'
    autoload :ListStyleDefinition, 'uniword/wordprocessingml/styles/list_style_definition'
    autoload :TableStyleDefinition, 'uniword/wordprocessingml/styles/table_style_definition'
    autoload :SemanticStyle, 'uniword/wordprocessingml/styles/semantic_style'
    autoload :Dsl, 'uniword/wordprocessingml/styles/dsl'
  end
end
