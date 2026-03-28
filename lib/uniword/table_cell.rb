# frozen_string_literal: true

# Compatibility shim: Uniword::TableCell delegates to Wordprocessingml::TableCell
# The OOXML model is defined in wordprocessingml/table_cell.rb

# Pre-load the OOXML TableCell so we can inherit from it
require 'lutaml/model'

module Uniword
  module Wordprocessingml
    class TableCell < ::Lutaml::Model::Serializable
      # OOXML TableCell definition is in wordprocessingml/table_cell.rb
      # This stub prevents circular requires during the require_relative below
    end
  end
end

# Now load the OOXML version and subclass it
require_relative 'wordprocessingml/table_cell'

module Uniword
  # Uniword::TableCell delegates to the OOXML model
  class TableCell < Wordprocessingml::TableCell
  end
end
