# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Properties
    # Page break before property
    #
    # Represents w:pageBreakBefore element in paragraph properties.
    # When present, starts a new page before the paragraph.
    #
    # Element: <w:pageBreakBefore/> or <w:pageBreakBefore w:val="false"/>
    class PageBreakBefore < Lutaml::Model::Serializable
      include BooleanElement

      attribute :val, :string, default: nil
      include BooleanValSetter

      xml do
        element "pageBreakBefore"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "val", to: :val, render_nil: false, render_default: false
      end
    end
  end
end
