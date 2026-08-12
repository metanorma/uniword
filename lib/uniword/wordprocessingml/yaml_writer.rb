# frozen_string_literal: true

module Uniword
  module Wordprocessingml
    # Internal helper for the models that map YAML keys through `with:`
    # transforms.
    #
    # lutaml-model hands a `to:` method the accumulating hash and throws its
    # return value away, so every writer has to assign into that hash.
    # Returning the value instead made to_yaml emit "--- {}" for a fully
    # populated model.
    module YamlWriter
      # Write one YAML key, skipping the ones this model does not set.
      #
      # @param doc [Hash] Accumulating YAML hash
      # @param key [String] YAML key to write
      # @param value [Object, nil] Value, or nil to leave the key out
      # @return [void]
      def yaml_put(doc, key, value)
        doc[key] = value unless value.nil?
      end
    end
  end
end
