# frozen_string_literal: true

module Uniword
  # Review module for comments and tracked changes management.
  #
  # Provides a unified API for working with document review features:
  # - Comments: listing, adding, resolving, removing
  # - Tracked changes: listing, accepting, rejecting
  # - Interactive TUI for reviewing changes one-by-one
  #
  # @see ReviewManager Orchestrator for comments and tracked changes
  # @see AcceptReject Individual revision accept/reject handling
  # @see InteractiveReview TUI for reviewing changes
  module Review
    autoload :AcceptReject, "uniword/review/accept_reject"
    autoload :ReviewManager, "uniword/review/review_manager"
    autoload :InteractiveReview, "uniword/review/interactive_review"
  end
end
