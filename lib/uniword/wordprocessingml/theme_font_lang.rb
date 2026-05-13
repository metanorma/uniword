# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    class ThemeFontLang < Lutaml::Model::Serializable
      attribute :val, :string
      attribute :east_asia, :string

      xml do
        element "themeFontLang"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "val", to: :val
        map_attribute "eastAsia", to: :east_asia
      end
    end
  end
end
