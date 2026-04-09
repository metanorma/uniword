# frozen_string_literal: true

# VmlWord namespace module
# This file explicitly autoloads all VmlWord classes
#
# VML Word - VML elements specific to Word documents
# Namespace: urn:schemas-microsoft-com:office:word
# Prefix: w:

module Uniword
  module VmlWord
    autoload :BorderTop, 'uniword/vml_word/border_top'
    autoload :BorderLeft, 'uniword/vml_word/border_left'
    autoload :BorderRight, 'uniword/vml_word/border_right'
    autoload :BorderBottom, 'uniword/vml_word/border_bottom'
  end
end
