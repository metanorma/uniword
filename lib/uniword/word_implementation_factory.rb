# frozen_string_literal: true

module Uniword
  # Separate factory class - follows Single Responsibility Principle
  class WordImplementationFactory
    def self.create
      case RbConfig::CONFIG['host_os']
      when /darwin/ then MacOSWordImplementation.new
      when /mswin|mingw|cygwin/ then WindowsWordImplementation.new
      when /linux/ then LinuxWordImplementation.new
      else NullWordImplementation.new
      end
    end
  end
end
