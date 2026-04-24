# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Presentationml
    # Presentation root element defining the main presentation structure
    #
    # Generated from OOXML schema: presentationml.yml
    # Element: <p:presentation>
    class Presentation < Lutaml::Model::Serializable
      attribute :sld_master_id_lst, SlideMasterIdList
      attribute :sld_id_lst, SlideIdList
      attribute :notes_master_id_lst, NotesMasterIdList
      attribute :handout_master_id_lst, HandoutMasterIdList
      attribute :sld_sz, SlideSize
      attribute :notes_sz, NotesSize
      attribute :default_text_style, :string
      attribute :color_map, :string
      attribute :embedded_font_lst, :string

      xml do
        element "presentation"
        namespace Uniword::Ooxml::Namespaces::PresentationalML
        mixed_content

        map_element "sldMasterIdLst", to: :sld_master_id_lst, render_nil: false
        map_element "sldIdLst", to: :sld_id_lst
        map_element "notesMasterIdLst", to: :notes_master_id_lst,
                                        render_nil: false
        map_element "handoutMasterIdLst", to: :handout_master_id_lst,
                                          render_nil: false
        map_element "sldSz", to: :sld_sz
        map_element "notesSz", to: :notes_sz
        map_element "defaultTextStyle", to: :default_text_style,
                                        render_nil: false
        map_element "colorMap", to: :color_map, render_nil: false
        map_element "embeddedFontLst", to: :embedded_font_lst, render_nil: false
      end
    end
  end
end
