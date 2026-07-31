# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Empty `<w:trackChanges/>` element in `<w:settings>` — Word's
    # Review → Track Changes toggle.
    #
    # When present, Word records every edit as a tracked change. When
    # absent, edits are applied silently.
    class TrackChanges < Lutaml::Model::Serializable
      xml do
        element "trackChanges"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
      end
    end
  end
end
