# frozen_string_literal: true

module Uniword
  module Plugin
    # Base class for plugin-provided CLI commands. A plugin CLI
    # command is a Thor subclass that the main CLI registers as a
    # subcommand.
    #
    # Subclasses declare `subcommand_name` (the name CLI users type)
    # and `description` (shown in `uniword help`).
    class CliCommand
      class << self
        # @return [Symbol] subcommand name (e.g. :myplugin)
        def subcommand_name
          raise NotImplementedError
        end

        # @return [String] one-line description
        def description
          raise NotImplementedError
        end

        # @return [Class<Thor>] the Thor subclass to register
        def thor_class
          raise NotImplementedError
        end
      end
    end
  end
end
