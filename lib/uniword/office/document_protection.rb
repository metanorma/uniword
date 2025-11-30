# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Office
    # Document protection settings
    #
    # Generated from OOXML schema: office.yml
    # Element: <o:DocumentProtection>
    class DocumentProtection < Lutaml::Model::Serializable
      attribute :edit, :string
      attribute :formatting, :string
      attribute :enforcement, :string

      xml do
        element 'DocumentProtection'
        namespace Uniword::Ooxml::Namespaces::Office

        map_attribute 'edit', to: :edit
        map_attribute 'formatting', to: :formatting
        map_attribute 'enforcement', to: :enforcement
      end
    end
  end
end
