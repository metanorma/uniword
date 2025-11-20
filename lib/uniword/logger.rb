# frozen_string_literal: true

require 'logger'

module Uniword
  # Simple logger wrapper for Uniword
  # Provides consistent logging across the library
  #
  # @example
  #   Uniword::Logger.info("Processing document")
  #   Uniword::Logger.warn("Deprecation warning")
  #   Uniword::Logger.error("Failed to process")
  module Logger
    class << self
      # Get or create the logger instance
      #
      # @return [::Logger] The logger instance
      def logger
        @logger ||= create_default_logger
      end

      # Set a custom logger
      #
      # @param custom_logger [::Logger] Custom logger instance
      # @return [::Logger] The logger that was set
      def logger=(custom_logger)
        @logger = custom_logger
      end

      # Log an info message
      #
      # @param message [String] The message to log
      # @return [void]
      def info(message)
        logger.info(message)
      end

      # Log a warning message
      #
      # @param message [String] The message to log
      # @return [void]
      def warn(message)
        logger.warn(message)
      end

      # Log an error message
      #
      # @param message [String] The message to log
      # @return [void]
      def error(message)
        logger.error(message)
      end

      # Log a debug message
      #
      # @param message [String] The message to log
      # @return [void]
      def debug(message)
        logger.debug(message)
      end

      private

      # Create default logger instance
      #
      # @return [::Logger] New logger instance
      def create_default_logger
        log = ::Logger.new($stdout)
        log.level = ::Logger::WARN
        log.formatter = proc do |severity, datetime, _progname, msg|
          "[Uniword] #{severity}: #{msg}\n"
        end
        log
      end
    end
  end
end