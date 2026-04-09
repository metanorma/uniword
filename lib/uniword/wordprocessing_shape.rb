# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  # WordprocessingShape namespace for VML-compatible shapes in DrawingML
  # Namespace: http://schemas.microsoft.com/office/word/2010/wordprocessingShape
  # Prefix: wps
  module WordprocessingShape
    # Text box within a wordprocessing shape
    # Contains w:txbxContent (WordprocessingML text box content)
    class Textbox < Lutaml::Model::Serializable
      attribute :txbx_content, Uniword::Wordprocessingml::TextBoxContent

      xml do
        root 'txbx'
        namespace Uniword::Ooxml::Namespaces::WordprocessingShape
        mixed_content

        map_element 'txbxContent', to: :txbx_content, render_nil: false
      end
    end

    # WordprocessingShape - a shape element that can contain text
    # Contains wps:txbx (text box), wps:bodyPr, wps:spPr, etc.
    class WordprocessingShape < Lutaml::Model::Serializable
      attribute :txbx, Textbox
      attribute :body_pr, Lutaml::Model::Serializable
      attribute :sp_pr, Lutaml::Model::Serializable
      attribute :c_nv_pr, Lutaml::Model::Serializable
      attribute :c_nv_sp_pr, Lutaml::Model::Serializable
      attribute :style, Lutaml::Model::Serializable

      xml do
        root 'wsp'
        namespace Uniword::Ooxml::Namespaces::WordprocessingShape
        mixed_content

        map_element 'txbx', to: :txbx, render_nil: false
        map_element 'bodyPr', to: :body_pr, render_nil: false
        map_element 'spPr', to: :sp_pr, render_nil: false
        map_element 'cNvPr', to: :c_nv_pr, render_nil: false
        map_element 'cNvSpPr', to: :c_nv_sp_pr, render_nil: false
        map_element 'style', to: :style, render_nil: false
      end
    end
  end
end
