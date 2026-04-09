# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Properties
    # Table justification element
    #
    # Represents <w:jc> element with val attribute for table alignment.
    # Used in table properties (w:tblPr) for table positioning.
    class TableJustification < Lutaml::Model::Serializable
      attribute :value, :string

      xml do
        element 'jc'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_attribute 'val', to: :value
      end
    end
  end
end
