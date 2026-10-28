# frozen_string_literal: true

module Uniword
  module Plugin
    # Discovers plugins from installed gems. Each plugin ships a
    # ruby file under `uniword/plugin/<name>.rb` that registers
    # itself with `Plugin::Registry` on load.
    class Loader
      GLOB = "uniword/plugin/*.rb"

      class << self
        # Load every plugin file found in installed gems.
        #
        # @return [Array<String>] paths loaded
        def load_all
          Gem.find_files(GLOB).each { |path| require path }
        end

        # Run every registered transformer whose `stages` include
        # `stage`, in registration order.
        #
        # @param document [Wordprocessingml::DocumentRoot]
        # @param stage [Symbol] one of `Transformer::STAGES`
        # @return [void]
        def run_transformers(document:, stage:)
          Registry.transformers.each_value do |transformer|
            next unless transformer.applies_to?(stage)

            transformer.transform(document)
          end
        end

        # Yield every registered validator in registration order.
        #
        # @yieldparam validator [Plugin::Validator]
        # @return [void]
        def each_validator(&block)
          Registry.validators.each_value(&block)
        end
      end
    end
  end
end
