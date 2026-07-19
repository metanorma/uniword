# frozen_string_literal: true

module Uniword
  module Docx
    class Reconciler
      # Single source of truth for record_fix rule codes.
      #
      # Every `record_fix` call site references a constant from this module
      # instead of a bare string literal. Adding a new fix category means
      # adding one constant here with the next free code.
      #
      # One code per concern: each constant has a unique, self-describing
      # wire value. Codes "R1".."R16" are frozen — external validation rules
      # (lib/uniword/validation/rules) and audit-log consumers pattern-match
      # on them, so the original concerns keep their historic codes. Codes
      # "R17" and up were introduced when the overloaded "R10" (and the
      # remaining shared codes "R4"/"R11"/"R12"/"R13") were split into
      # per-concern values.
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

        # Notes — pair creation and definition integrity
        NOTE_PAIR_CREATED = "R9"
        NOTE_DEFINITION_CREATED = "R10"
        NOTE_INVALID_TYPE_STRIPPED = "R15"
        NOTE_DUPLICATE_ID_REMOVED = "R16"

        # Body
        SECTION_PROPERTIES_DEFAULTED = "R11"
        PARAGRAPH_BACKFILL = "R12"

        # Parts
        FONT_TABLE_CREATED = "R13"
        CORE_PROPERTIES_REBUILT = "R14"

        # Referential integrity — dangling-reference repairs (split from
        # the overloaded R10/R4/R11/R12 codes; one code per concern)
        DANGLING_NUMBERING_REMOVED = "R17"
        DANGLING_NOTE_REFERENCE_REMOVED = "R18"
        DANGLING_STYLE_REFERENCE_REMOVED = "R19"
        DANGLING_BASED_ON_REMOVED = "R20"
        DANGLING_HYPERLINK_REMOVED = "R21"
        DANGLING_HEADER_FOOTER_REMOVED = "R22"
        DANGLING_DRAWING_REMOVED = "R23"
        DANGLING_RELATIONSHIP_TARGET_REMOVED = "R32"

        # Referential integrity — literal hyperlink targets promoted to
        # proper External relationships (repairs Builder.hyperlink output)
        HYPERLINK_RELATIONSHIP_CREATED = "R31"

        # Styles
        STYLE_DEFAULTS_ADDED = "R24"
        SEMI_HIDDEN_ADDED = "R25"

        # Tables
        TABLE_STRUCTURE_RECONCILED = "R26"
        TABLE_CELL_PR_REORDERED = "R27"
        TABLE_CELL_DEFAULTS = "R28"
        TABLE_ROW_GRID_AFTER = "R29"

        # Run cleanup
        EMPTY_RUNS_STRIPPED = "R30"

        # Tables — gridCol widths defaulted to equal shares of the
        # section content width (Word's fallback behavior)
        TABLE_GRID_COL_WIDTHS_DEFAULTED = "R33"
      end
    end
  end
end
