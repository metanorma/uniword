# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Office
    # Document view settings
    #
    # Generated from OOXML schema: office.yml
    # Element: <o:view>
    class DocumentView < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "view"
        namespace Uniword::Ooxml::Namespaces::Office

        map_attribute "val", to: :val
      end
    end
  end
end
