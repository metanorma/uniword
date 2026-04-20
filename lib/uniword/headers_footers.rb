# frozen_string_literal: true

module Uniword
  # Header and footer management for documents.
  #
  # Provides operations for listing, adding, updating, and removing
  # headers and footers from documents. Supports default, first-page,
  # and even-page header/footer types.
  module HeadersFooters
    autoload :Manager, "uniword/headers_footers/manager"
  end
end
