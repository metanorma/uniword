# frozen_string_literal: true

module Uniword
  # Document protection for editing restrictions.
  #
  # Provides operations for setting and removing document editing
  # restrictions with optional password protection.
  module Protect
    autoload :Manager, "uniword/protect/manager"
  end
end
