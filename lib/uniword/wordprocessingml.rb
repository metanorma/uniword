# frozen_string_literal: true

# Generated WordprocessingML classes loader
# This file autoloads all generated classes from lib/uniword/wordprocessingml/
# Using autoload instead of require to handle circular dependencies

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Autoload all generated wordprocessingml classes
    # This allows circular dependencies to resolve naturally
    Dir[File.join(__dir__, 'wordprocessingml', '*.rb')].sort.each do |file|
      class_name = File.basename(file, '.rb')
        .split('_')
        .map(&:capitalize)
        .join
      
      autoload class_name.to_sym, file
    end
  end
end