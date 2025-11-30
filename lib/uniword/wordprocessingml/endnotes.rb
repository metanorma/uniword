# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Endnotes collection
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:endnotes>
    class Endnotes < Lutaml::Model::Serializable
      attribute :endnote_entries, Endnote, collection: true, default: -> { [] }

      xml do
        element 'endnotes'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_element 'endnote', to: :endnote_entries, render_nil: false
      end
    end
  end
end
