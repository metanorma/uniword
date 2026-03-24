# frozen_string_literal: true

# Top-level class aliases for API compatibility
# These provide convenience access to nested classes at the Uniword module level
#
# The main OOXML model classes live in Uniword::Wordprocessingml::*.
# These aliases make the API more convenient for common operations.
#
# @example
#   Uniword::Document.new      # alias for Wordprocessingml::DocumentRoot
#   Uniword::Paragraph.new     # alias for Wordprocessingml::Paragraph
#   Uniword::Table.new         # alias for Wordprocessingml::Table

module Uniword
  # Document alias (see Wordprocessingml::DocumentRoot)
  Document = Wordprocessingml::DocumentRoot

  # Paragraph alias (see Wordprocessingml::Paragraph)
  Paragraph = Wordprocessingml::Paragraph

  # Table alias (see Wordprocessingml::Table)
  Table = Wordprocessingml::Table

  # Run alias (see Wordprocessingml::Run)
  Run = Wordprocessingml::Run

  # TableRowProperties alias (see Wordprocessingml::TableRowProperties)
  TableRowProperties = Wordprocessingml::TableRowProperties

  # TableCellProperties alias (see Wordprocessingml::TableCellProperties)
  TableCellProperties = Wordprocessingml::TableCellProperties

  # Serialization module alias (see Uniword::Serialization)
  # Defined in uniword/serialization/ooxml_serializer.rb
  autoload :Serialization, 'uniword/serialization/ooxml_serializer'
end
