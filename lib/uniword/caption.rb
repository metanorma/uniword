# frozen_string_literal: true

module Uniword
  # Auto-numbered figure/table/equation captions with cross-references
  # and Tables of Figures.
  #
  # Three pieces, all model-driven:
  #
  # - `Caption::Counter` — label-keyed counters (Figure, Table,
  #   Equation) persisted on the document. Reset to 1 at the start
  #   of each document load.
  # - `Caption::CaptionBuilder` — builds a Caption-styled paragraph
  #   with a SEQ field, returns the assigned bookmark name.
  # - `Caption::CrossReference` — builds a REF fldSimple targeting a
  #   named bookmark.
  #
  # The TOC of figures is just the existing TOC engine with `\c`
  # instead of `\o`; see `Toc::FigureEntryBuilder`.
  module Caption
    autoload :Counter, "#{__dir__}/caption/counter"
    autoload :CaptionBuilder, "#{__dir__}/caption/caption_builder"
    autoload :CrossReference, "#{__dir__}/caption/cross_reference"
  end
end
