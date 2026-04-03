# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Deleted text in revision tracking
    #
    # Element: <w:delText>
    # Contains text that was deleted during revision tracking.
    # Same structure as Text but uses delText element name.
    class DeletedText < Lutaml::Model::Serializable
      attribute :content, :string
      attribute :xml_space, :string

      xml do
        element 'delText'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_attribute 'xml:space', to: :xml_space, render_nil: false
      end

      def to_s
        content.to_s
      end
    end
  end
end
