# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Mhtml
    module Metadata
      # o:OfficeDocumentSettings — Office document settings from MHTML.
      class OfficeDocumentSettings < Lutaml::Model::Serializable
        attribute :allow_png, :string
        attribute :pixels_per_inch, :string

        xml do
          element 'OfficeDocumentSettings'
          namespace Uniword::Mhtml::Namespaces::Office
          map_element 'AllowPNG', to: :allow_png
          map_element 'PixelsPerInch', to: :pixels_per_inch
        end
      end
    end
  end
end
