# frozen_string_literal: true

# Presentationml namespace module
# This file explicitly autoloads all Presentationml classes
# Using explicit autoload instead of dynamic Dir[] for maintainability
#
# PresentationML namespace - PowerPoint support
# Namespace: http://schemas.openxmlformats.org/presentationml/2006/main
# Prefix: p:
# Generated: 2024-11-28

require 'lutaml/model'

module Uniword
  module Presentationml
    # Autoload all Presentationml classes (51)
    autoload :Audio, 'uniword/presentationml/audio'
    autoload :BodyProperties, 'uniword/presentationml/body_properties'
    autoload :Break, 'uniword/presentationml/break'
    autoload :ColorMap, 'uniword/presentationml/color_map'
    autoload :CommonSlideData, 'uniword/presentationml/common_slide_data'
    autoload :CommonTimeNode, 'uniword/presentationml/common_time_node'
    autoload :ConnectionShape, 'uniword/presentationml/connection_shape'
    autoload :Embed, 'uniword/presentationml/embed'
    autoload :EmbeddedFont, 'uniword/presentationml/embedded_font'
    autoload :EndConditionsList, 'uniword/presentationml/end_conditions_list'
    autoload :EndParagraphRunProperties, 'uniword/presentationml/end_paragraph_run_properties'
    autoload :Extension, 'uniword/presentationml/extension'
    autoload :ExtensionList, 'uniword/presentationml/extension_list'
    autoload :Field, 'uniword/presentationml/field'
    autoload :GraphicFrame, 'uniword/presentationml/graphic_frame'
    autoload :GroupShape, 'uniword/presentationml/group_shape'
    autoload :HandoutMaster, 'uniword/presentationml/handout_master'
    autoload :HandoutMasterIdList, 'uniword/presentationml/handout_master_id_list'
    autoload :ListStyle, 'uniword/presentationml/list_style'
    autoload :NonVisualShapeProperties, 'uniword/presentationml/non_visual_shape_properties'
    autoload :Notes, 'uniword/presentationml/notes'
    autoload :NotesMasterIdList, 'uniword/presentationml/notes_master_id_list'
    autoload :NotesSize, 'uniword/presentationml/notes_size'
    autoload :OleObject, 'uniword/presentationml/ole_object'
    autoload :Paragraph, 'uniword/presentationml/paragraph'
    autoload :ParagraphProperties, 'uniword/presentationml/paragraph_properties'
    autoload :ParallelTimeNode, 'uniword/presentationml/parallel_time_node'
    autoload :Picture, 'uniword/presentationml/picture'
    autoload :Presentation, 'uniword/presentationml/presentation'
    autoload :Run, 'uniword/presentationml/run'
    autoload :RunProperties, 'uniword/presentationml/run_properties'
    autoload :SequenceTimeNode, 'uniword/presentationml/sequence_time_node'
    autoload :Shape, 'uniword/presentationml/shape'
    autoload :ShapeProperties, 'uniword/presentationml/shape_properties'
    autoload :ShapeTree, 'uniword/presentationml/shape_tree'
    autoload :Slide, 'uniword/presentationml/slide'
    autoload :SlideId, 'uniword/presentationml/slide_id'
    autoload :SlideIdList, 'uniword/presentationml/slide_id_list'
    autoload :SlideLayout, 'uniword/presentationml/slide_layout'
    autoload :SlideMaster, 'uniword/presentationml/slide_master'
    autoload :SlideMasterId, 'uniword/presentationml/slide_master_id'
    autoload :SlideMasterIdList, 'uniword/presentationml/slide_master_id_list'
    autoload :SlideSize, 'uniword/presentationml/slide_size'
    autoload :StartConditionsList, 'uniword/presentationml/start_conditions_list'
    autoload :TextBody, 'uniword/presentationml/text_body'
    autoload :TimeNodeList, 'uniword/presentationml/time_node_list'
    autoload :Timing, 'uniword/presentationml/timing'
    autoload :Transition, 'uniword/presentationml/transition'
    autoload :Video, 'uniword/presentationml/video'
  end
end