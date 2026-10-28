# frozen_string_literal: true

module Uniword
  module Cli
    # Rewrites help/version flag invocations before Thor dispatch so
    # help works on tasks with required arguments:
    #
    #   uniword convert --help        → uniword help convert
    #   uniword images add --help     → uniword help images add
    #   uniword --help / -h           → root help
    #   uniword --version / -V        → uniword version
    #
    # The rewrite only fires when the help/version flag is the first
    # flag-like token and everything before it looks like a task path
    # (no options), so real option values (e.g. `--from docx`) are
    # never mistaken for the chain.
    module HelpSwitch
      HELP_FLAGS = %w[--help -h].freeze
      VERSION_FLAGS = %w[--version -V].freeze

      def start(given_args = ARGV, config = {})
        args = given_args.map(&:to_s)

        if (help_idx = args.index { |a| HELP_FLAGS.include?(a) })
          chain = args[0...help_idx]
          if option_free_task_path?(chain)
            return super(chain.unshift("help"), config)
          end
        end

        if args.size == 1 && VERSION_FLAGS.include?(args[0])
          return super(["version"], config)
        end

        super
      end

      private

      def option_free_task_path?(chain)
        chain.all? { |a| !a.start_with?("-") }
      end
    end
  end
end
