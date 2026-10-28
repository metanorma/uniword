# frozen_string_literal: true

module Uniword
  module Diff
    # Element-level semantic diff. Builds on the existing
    # DocumentDiffer (paragraph LCS) to produce a structured change
    # report where each change has a classification:
    #
    # - `:added` — element only in new
    # - `:removed` — element only in old
    # - `:modified` — element in both but different; sub-classified
    #   by what changed (`:text`, `:format`, `:structure`)
    # - `:moved` — element in both, same content, different position
    #
    # Open/closed: a new element kind to compare (images, tables,
    # styles) = a new `Comparator` subclass + registration in
    # `Engine::COMPARATORS`.
    module Semantic
      autoload :Engine, "#{__dir__}/semantic/engine"
      autoload :Change, "#{__dir__}/semantic/change"
      autoload :Result, "#{__dir__}/semantic/result"
      autoload :ParagraphComparator,
               "#{__dir__}/semantic/paragraph_comparator"
    end
  end
end
