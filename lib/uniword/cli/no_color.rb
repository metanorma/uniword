# frozen_string_literal: true

module Uniword
  module Cli
    # POSIX NO_COLOR convention (https://no-color.org/): when the
    # environment variable is set (to any non-empty value), colored
    # CLI output must be suppressed. Prepended onto Thor's shell only
    # when the variable is present, so the zero-cost path is the norm.
    module NoColor
      def color?
        return false if ENV["NO_COLOR"] && !ENV["NO_COLOR"].empty?

        super
      end
    end
  end
end

require "thor/shell/basic"

Thor::Shell::Basic.prepend(Uniword::Cli::NoColor)
