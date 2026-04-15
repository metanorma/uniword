# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Drawingml
    # Use Local DPI element for Office 2010 extensions
    #
    # Element: <a14:useLocalDpi>
    class UseLocalDpi < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "useLocalDpi"
        namespace Uniword::Ooxml::Namespaces::Drawing2010

        map_attribute "val", to: :val
      end
    end
  end
end
