# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Mail merge recipient data
    #
    # Element: <recipientData>
    class RecipientData < Lutaml::Model::Serializable
      attribute :active, SharedTypes::OnOff
      attribute :column, SharedTypes::DecimalNumber
      attribute :unique_tag, :string

      xml do
        element "recipientData"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_element "active", to: :active, render_nil: false
        map_element "column", to: :column, render_nil: false
        map_element "uniqueTag", to: :unique_tag, render_nil: false
      end
    end
  end
end
