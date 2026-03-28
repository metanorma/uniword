# frozen_string_literal: true

# Compatibility shim: Uniword::TableRow delegates to Wordprocessingml::TableRow
# The OOXML model is defined in wordprocessingml/table_row.rb
#
# This file redefines Uniword::TableRow as a subclass of Wordprocessingml::TableRow
# to maintain additional API methods (copy, insert_before, parent_table, etc.)
# while using the correct OOXML model for serialization.
#
# @example
#   row = Uniword::TableRow.new
#   row.add_cell(Uniword::TableCell.new)
#   row.properties = Uniword::Wordprocessingml::TableRowProperties.new(header: true)

# Pre-load the OOXML TableRow so we can inherit from it
require 'lutaml/model'

module Uniword
  module Wordprocessingml
    class TableRow < ::Lutaml::Model::Serializable
      # OOXML TableRow definition is in wordprocessingml/table_row.rb
      # This stub prevents circular requires during the require_relative below
    end
  end
end

# Now load the OOXML version and subclass it
require_relative 'wordprocessingml/table_row'

module Uniword
  # Override Uniword::TableRow to delegate to the OOXML model
  # while keeping additional API methods
  class TableRow < Wordprocessingml::TableRow
    # Additional API methods not in the OOXML model

    # Create a deep copy of this row
    #
    # @return [TableRow] A new row with copied cells
    def copy
      new_row = TableRow.new
      cells.each do |cell|
        new_cell = TableCell.new
        new_cell.properties = cell.properties.dup if cell.properties

        cell.paragraphs.each do |para|
          new_para = Paragraph.new
          para.runs.each do |run|
            new_run = Run.new(text: run.text)
            new_run.properties = run.properties.dup if run.properties
            new_para.runs << new_run
          end
          new_cell.paragraphs << new_para
        end

        new_row.cells << new_cell
      end
      new_row
    end

    # Insert this row before another row in the table
    #
    # @param other_row [TableRow] The row to insert before
    # @return [self] Returns self for method chaining
    def insert_before(other_row)
      return self unless other_row.parent_table

      parent_table = other_row.parent_table
      idx = parent_table.rows.index(other_row)
      return self unless idx

      parent_table.rows.insert(idx, self)
      self.parent_table = parent_table
      self
    end

    # Parent table accessor (set by table when added)
    attr_accessor :parent_table

    # Check if row is empty (has no cells or all cells are empty)
    #
    # @return [Boolean] true if empty
    def empty?
      cells.empty? || cells.all?(&:empty?)
    end

    # Check if this is a header row
    #
    # @return [Boolean] true if header row
    def header?
      properties&.header == true
    end

    # Override equality to use object identity
    #
    # @param other [Object] The object to compare with
    # @return [Boolean] true if same object
    def ==(other)
      equal?(other)
    end

    alias eql? ==
  end
end
