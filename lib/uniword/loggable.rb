# frozen_string_literal: true

module Uniword
  # A mixin module that provides logging capabilities to classes.
  #
  # Classes that include this module gain access to logging methods
  # that delegate to the global Uniword logger.
  #
  # @example
  #   class MyClass
  #     include Uniword::Loggable
  #
  #     def do_something
  #       log_debug("Starting operation")
  #       # ... do work ...
  #       log_info("Operation completed")
  #     rescue => e
  #       log_error("Operation failed: #{e.message}")
  #     end
  #   end
  module Loggable
    # Returns the Uniword logger instance
    #
    # @return [Logger] The Uniword logger
    def logger
      Uniword.logger
    end

    # Log a debug message
    #
    # @param message [String] The message to log
    def log_debug(message)
      logger.debug(message)
    end

    # Log an info message
    #
    # @param message [String] The message to log
    def log_info(message)
      logger.info(message)
    end

    # Log a warning message
    #
    # @param message [String] The message to log
    def log_warn(message)
      logger.warn(message)
    end

    # Log an error message
    #
    # @param message [String] The message to log
    def log_error(message)
      logger.error(message)
    end
  end
end
