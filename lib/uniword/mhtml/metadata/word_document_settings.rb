# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Mhtml
    module Metadata
      # w:WordDocument — Word document settings from MHTML HTML head.
      #
      # Contains settings like TrackMoves, TrackFormatting, language IDs,
      # compatibility options, and math properties.
      class WordDocumentSettings < Lutaml::Model::Serializable
        attribute :track_moves, :string
        attribute :track_formatting, :string
        attribute :punctuation_kerning, :string
        attribute :validate_against_schemas, :string
        attribute :save_if_xml_invalid, :string
        attribute :ignore_mixed_content, :string
        attribute :always_show_placeholder_text, :string
        attribute :do_not_promote_qf, :string
        attribute :lid_theme_other, :string
        attribute :lid_theme_asian, :string
        attribute :lid_theme_complex_script, :string
        attribute :compatibility_raw, :string
        attribute :math_properties_raw, :string

        xml do
          element "WordDocument"
          namespace Uniword::Mhtml::Namespaces::Word
          map_element 'TrackMoves', to: :track_moves
          map_element 'TrackFormatting', to: :track_formatting
          map_element 'PunctuationKerning', to: :punctuation_kerning
          map_element 'ValidateAgainstSchemas', to: :validate_against_schemas
          map_element 'SaveIfXMLInvalid', to: :save_if_xml_invalid
          map_element 'IgnoreMixedContent', to: :ignore_mixed_content
          map_element 'AlwaysShowPlaceholderText', to: :always_show_placeholder_text
          map_element 'DoNotPromoteQF', to: :do_not_promote_qf
          map_element 'LidThemeOther', to: :lid_theme_other
          map_element 'LidThemeAsian', to: :lid_theme_asian
          map_element 'LidThemeComplexScript', to: :lid_theme_complex_script
          map_element 'Compatibility', to: :compatibility_raw
          map_element 'mathPr', to: :math_properties_raw
        end
      end
    end
  end
end
