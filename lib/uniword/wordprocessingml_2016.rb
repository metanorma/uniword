# frozen_string_literal: true

# Wordprocessingml2016 namespace module
# This file explicitly autoloads all Wordprocessingml2016 classes
# Using explicit autoload instead of dynamic Dir[] for maintainability
#
# WordprocessingML 2016 Extended namespace
# Namespace: http://schemas.microsoft.com/office/word/2016/wordml
# Prefix: w16:
# Generated classes for Word 2016 features

require "lutaml/model"

module Uniword
  module Wordprocessingml2016
    # Autoload all Wordprocessingml2016 classes (15)
    autoload :CellRsid, "uniword/wordprocessingml_2016/cell_rsid"
    autoload :ChartColorStyle, "uniword/wordprocessingml_2016/chart_color_style"
    autoload :ChartStyle2016, "uniword/wordprocessingml_2016/chart_style2016"
    autoload :CommentsExt, "uniword/wordprocessingml_2016/comments_ext"
    autoload :ConflictMode2016, "uniword/wordprocessingml_2016/conflict_mode2016"
    autoload :ContentId, "uniword/wordprocessingml_2016/content_id"
    autoload :DataBinding2016, "uniword/wordprocessingml_2016/data_binding2016"
    autoload :ExtensionList, "uniword/wordprocessingml_2016/extension_list"
    autoload :Extension, "uniword/wordprocessingml_2016/extension"
    autoload :PersistentDocumentId, "uniword/wordprocessingml_2016/persistent_document_id"
    autoload :RowRsid, "uniword/wordprocessingml_2016/row_rsid"
    autoload :SdtAppearance2016, "uniword/wordprocessingml_2016/sdt_appearance2016"
    autoload :SeparatorExtension, "uniword/wordprocessingml_2016/separator_extension"
    autoload :TableRsid, "uniword/wordprocessingml_2016/table_rsid"
    autoload :WebVideoProperty, "uniword/wordprocessingml_2016/web_video_property"
  end
end
