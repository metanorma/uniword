# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Office
    # Writing style settings
    #
    # Generated from OOXML schema: office.yml
    # Element: <o:writingstyle>
    class WritingStyle < Lutaml::Model::Serializable
      attribute :lang, :string
      attribute :vendorID, :string
      attribute :dllVersion, :string
      attribute :nlcheck, :string

      xml do
        element "writingstyle"
        namespace Uniword::Ooxml::Namespaces::Office

        map_attribute "lang", to: :lang
        map_attribute "vendorID", to: :vendorID
        map_attribute "dllVersion", to: :dllVersion
        map_attribute "nlcheck", to: :nlcheck
      end
    end
  end
end
