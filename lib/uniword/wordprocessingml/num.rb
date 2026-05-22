# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Numbering instance
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:num>
    class Num < Lutaml::Model::Serializable
      attribute :numId, :integer
      attribute :durable_id, :string
      attribute :abstractNumId, AbstractNumId
      attribute :lvlOverrides, LevelOverride, collection: true,
                                              initialize_empty: true

      xml do
        element "num"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_attribute "numId", to: :numId
        map_attribute "durableId", to: :durable_id,
                                   namespace: Uniword::Ooxml::Namespaces::Word2016Cid,
                                   render_nil: false
        map_element "abstractNumId", to: :abstractNumId, render_nil: false
        map_element "lvlOverride", to: :lvlOverrides, render_nil: false
      end
    end
  end
end
