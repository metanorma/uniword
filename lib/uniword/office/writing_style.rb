# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Office
    # Writing style settings
    #
    # Generated from OOXML schema: office.yml
    # Element: <o:writingstyle>
    class WritingStyle < Lutaml::Model::Serializable
      attribute :lang, String
      attribute :vendorID, String
      attribute :dllVersion, String
      attribute :nlcheck, String

      xml do
        element 'writingstyle'
        namespace Uniword::Ooxml::Namespaces::Office

        map_attribute 'lang', to: :lang
        map_attribute 'vendorID', to: :vendorID
        map_attribute 'dllVersion', to: :dllVersion
        map_attribute 'nlcheck', to: :nlcheck
      end
    end
  end
end
