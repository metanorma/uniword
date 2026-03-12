# frozen_string_literal: true

module Uniword
  module Sdt
    autoload :Id, "#{__dir__}/sdt/id"
    autoload :Alias, "#{__dir__}/sdt/alias"
    autoload :Tag, "#{__dir__}/sdt/tag"
    autoload :Text, "#{__dir__}/sdt/text"
    autoload :ShowingPlaceholderHeader, "#{__dir__}/sdt/showing_placeholder_header"
    autoload :Appearance, "#{__dir__}/sdt/appearance"
    autoload :Placeholder, "#{__dir__}/sdt/placeholder"
    autoload :DataBinding, "#{__dir__}/sdt/data_binding"
    autoload :Bibliography, "#{__dir__}/sdt/bibliography"
    autoload :Temporary, "#{__dir__}/sdt/temporary"
    autoload :DocPartObj, "#{__dir__}/sdt/doc_part_obj"
    autoload :Date, "#{__dir__}/sdt/date"
    autoload :RunProperties, "#{__dir__}/sdt/run_properties"
  end
end
