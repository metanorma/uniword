# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    class EndnotePr < Lutaml::Model::Serializable
      attribute :endnotes, Endnote, collection: true

      xml do
        element "endnotePr"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content
        map_element "endnote", to: :endnotes, render_nil: false
      end
    end
  end
end
