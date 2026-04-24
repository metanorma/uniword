# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Mail merge recipients container
    #
    # Element: <recipients>
    class Recipients < Lutaml::Model::Serializable
      attribute :recipient_data, RecipientData, collection: true,
                                                initialize_empty: true

      xml do
        element "recipients"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_element "recipientData", to: :recipient_data, render_nil: false
      end
    end
  end
end
