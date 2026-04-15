# frozen_string_literal: true

# Word2010Ext namespace module
# Namespace: urn:schemas-microsoft-com:office:word
# Prefix: w10:
# Word 2010 extensibility elements used in VML

require "lutaml/model"

module Uniword
  module Word2010Ext
    autoload :Wrap, "uniword/word2010_ext/wrap"
  end
end
