# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Use East Asian Layout compatibility (empty marker element)
    #
    # Element: <w:useFELayout>
    class UseFELayout < Lutaml::Model::Serializable
      xml do
        element "useFELayout"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
      end
    end

    # Do not use HTML paragraph auto spacing (empty marker element)
    #
    # Element: <w:doNotUseHTMLParagraphAutoSpacing>
    # Parent: <w:compat>
    class DoNotUseHTMLParagraphAutoSpacing < Lutaml::Model::Serializable
      xml do
        element "doNotUseHTMLParagraphAutoSpacing"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
      end
    end

    # Compatibility settings
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:compat>
    class Compat < Lutaml::Model::Serializable
      attribute :use_fe_layout, UseFELayout
      attribute :do_not_use_html_paragraph_auto_spacing,
                DoNotUseHTMLParagraphAutoSpacing
      attribute :compatSetting, CompatSetting, collection: true,
                                               initialize_empty: true

      xml do
        element "compat"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_element "useFELayout", to: :use_fe_layout, render_nil: false
        map_element "doNotUseHTMLParagraphAutoSpacing",
                    to: :do_not_use_html_paragraph_auto_spacing,
                    render_nil: false
        map_element "compatSetting", to: :compatSetting, render_nil: false
      end
    end
  end
end
