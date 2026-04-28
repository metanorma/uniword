# frozen_string_literal: true

# Wordprocessingml2013 namespace module
# This file explicitly autoloads all Wordprocessingml2013 classes
# Using explicit autoload instead of dynamic Dir[] for maintainability
#
# WordprocessingML 2013 Extended namespace
# Namespace: http://schemas.microsoft.com/office/word/2013/wordml
# Prefix: w15:
# Generated classes for Word 2013 features

require "lutaml/model"

module Uniword
  module Wordprocessingml2013
    # Autoload all Wordprocessingml2013 classes (20)
    autoload :ChartProps, "uniword/wordprocessingml_2013/chart_props"
    autoload :ChartTrackingRefBased,
             "uniword/wordprocessingml_2013/chart_tracking_ref_based"
    autoload :CommentAuthor, "uniword/wordprocessingml_2013/comment_author"
    autoload :CommentCollapsed,
             "uniword/wordprocessingml_2013/comment_collapsed"
    autoload :CommentDone, "uniword/wordprocessingml_2013/comment_done"
    autoload :CommentEx, "uniword/wordprocessingml_2013/comment_ex"
    autoload :CommentsIds, "uniword/wordprocessingml_2013/comments_ids"
    autoload :DocPartAnchor, "uniword/wordprocessingml_2013/doc_part_anchor"
    autoload :DocumentPart, "uniword/wordprocessingml_2013/document_part"
    autoload :FootnoteColumns, "uniword/wordprocessingml_2013/footnote_columns"
    autoload :PeopleGroup, "uniword/wordprocessingml_2013/people_group"
    autoload :Person, "uniword/wordprocessingml_2013/person"
    autoload :PresenceInfo, "uniword/wordprocessingml_2013/presence_info"
    autoload :RepeatingSectionItem,
             "uniword/wordprocessingml_2013/repeating_section_item"
    autoload :RepeatingSection,
             "uniword/wordprocessingml_2013/repeating_section"
    autoload :SdtAppearance, "uniword/wordprocessingml_2013/sdt_appearance"
    autoload :SdtColor, "uniword/wordprocessingml_2013/sdt_color"
    autoload :SdtDataBinding, "uniword/wordprocessingml_2013/sdt_data_binding"
    autoload :WebExtensionLinked,
             "uniword/wordprocessingml_2013/web_extension_linked"
    autoload :WebExtension, "uniword/wordprocessingml_2013/web_extension"
  end
end
