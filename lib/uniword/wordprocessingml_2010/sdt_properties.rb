# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml2010
    # Structured document tag properties
    #
    # Generated from OOXML schema: wordprocessingml_2010.yml
    # Element: <w14:sdtPr>
    class SdtProperties < Lutaml::Model::Serializable
      attribute :checkbox, Checkbox
      attribute :doc_part_obj, DocPartObj
      attribute :data_binding, String

      xml do
        element 'sdtPr'
        namespace Uniword::Ooxml::Namespaces::Word2010
        mixed_content

        map_element 'checkbox', to: :checkbox, render_nil: false
        map_element 'docPartObj', to: :doc_part_obj, render_nil: false
        map_element 'dataBinding', to: :data_binding, render_nil: false
      end
    end
  end
end
