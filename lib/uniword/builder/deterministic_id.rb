# frozen_string_literal: true

require "digest"

module Uniword
  module Builder
    # Shared deterministic ID generation for builders.
    #
    # Produces stable integer IDs from seed values using SHA256,
    # ensuring reproducible output across runs.
    module DeterministicId
      private

      def deterministic_id(*seeds)
        Digest::SHA256.hexdigest(seeds.join(":")).to_i(16) % 1_000_000_000
      end
    end
  end
end
