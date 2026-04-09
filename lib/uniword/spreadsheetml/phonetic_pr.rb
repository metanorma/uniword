# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Spreadsheetml
    # Phonetic Properties
    #
    # Complex type for phonetic properties (furigana/reading marks).
    class PhoneticPr < Lutaml::Model::Serializable
      attribute :font_id, :integer
      attribute :typeface, :string
      attribute :panose, :string
      attribute :pitch_family, :integer
      attribute :charset, :integer
      attribute :alt_text, :string
      attribute :combination_id, :integer
      attribute :growing_editing, :string

      xml do
        element 'phoneticPr'
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML

        map_attribute 'fontId', to: :font_id, render_nil: false
        map_attribute 'typeface', to: :typeface, render_nil: false
        map_attribute 'panose', to: :panose, render_nil: false
        map_attribute 'pitchFamily', to: :pitch_family, render_nil: false
        map_attribute 'charset', to: :charset, render_nil: false
        map_attribute 'altText', to: :AltText, render_nil: false
        map_attribute 'combinationId', to: :combination_id, render_nil: false
        map_attribute 'growingEditing', to: :growing_editing, render_nil: false
      end
    end
  end
end
