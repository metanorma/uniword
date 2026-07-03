# frozen_string_literal: true

module Uniword
  module Docx
    class Reconciler
      # Single source of truth for record_fix rule codes.
      #
      # Every `record_fix` call site references a constant from this module
      # instead of a bare string literal. Adding a new fix category means
      # adding one constant here, not hunting for the next free letter.
      #
      # Wire format is preserved — external validation rules and audit-log
      # consumers that pattern-match on "R1".."R16" continue to work.
      #
      # Known debt: R10 is overloaded for several distinct concerns
      # (note defs, table structure, style defaults, dangling refs).
      # Splitting requires consumer coordination.
      module FixCodes
        # Settings / package structure
        MC_IGNORABLE = "R1"
        DOC_ID_GENERATED = "R2"

        # Support parts
        THEME_CREATED = "R3"
        NUMBERING_REFERENCED = "R4"

        # Package assembly
        RELATIONSHIPS_ASSEMBLED = "R6"
        CONTENT_TYPES_ASSEMBLED = "R7"
        APP_PROPERTIES_ENSURED = "R8"

        # Notes — pair creation
        NOTE_PAIR_CREATED = "R9"
        NOTE_DEFINITION_CREATED = "R10"
        NOTE_INVALID_TYPE_STRIPPED = "R15"
        NOTE_DUPLICATE_ID_REMOVED = "R16"

        # Notes — referential integrity warnings and removals
        DANGLING_NOTE_REFERENCE_WARNING = "R9"
        DANGLING_NOTE_REFERENCE_REMOVED = "R10"
        DANGLING_HYPERLINK_WARNING = "R9"

        # Body
        SECTION_PROPERTIES_DEFAULTED = "R11"
        PARAGRAPH_BACKFILL = "R12"

        # Parts
        FONT_TABLE_CREATED = "R13"
        CORE_PROPERTIES_REBUILT = "R14"

        # Styles (currently shares R10 with other concerns — see debt note above)
        STYLE_DEFAULTS_ADDED = "R10"
        SEMI_HIDDEN_ADDED = "R10"

        # Tables (currently shares R10)
        TABLE_STRUCTURE_RECONCILED = "R10"
        TABLE_CELL_PR_REORDERED = "R10"
        TABLE_CELL_DEFAULTS = "R12"
        TABLE_ROW_GRID_AFTER = "R13"

        # Referential integrity (currently shares R10)
        DANGLING_STYLE_REFERENCE_REMOVED = "R10"
        DANGLING_BASED_ON_REMOVED = "R10"
        DANGLING_NUMBERING_REMOVED = "R4"
        DANGLING_HYPERLINK_REMOVED = "R10"
        DANGLING_HEADER_FOOTER_REMOVED = "R11"
        DANGLING_DRAWING_REMOVED = "R12"

        # Run cleanup (currently shares R10)
        EMPTY_RUNS_STRIPPED = "R10"
      end
    end
  end
end
