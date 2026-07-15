# frozen_string_literal: true

require "omml"

module Uniword
  # Registers Uniword's WordprocessingML classes as substitutions for
  # Omml::Models' minimal WordprocessingML stubs. When an Omml model
  # (e.g. CTOMath) resolves a WordprocessingML type symbol (e.g.
  # +:ct_br+), the Register's substitution table redirects resolution
  # to the corresponding Uniword class.
  #
  # This keeps a single source of truth for WordprocessingML types:
  # Uniword owns the rich, builder-friendly classes; omml owns the math
  # schema. The two meet through register substitution, not through
  # duplicate model definitions.
  module OmmlIntegration
    SUBSTITUTIONS = {
      "Omml::Models::CTBr" => "Uniword::Wordprocessingml::Break",
    }.freeze

    class << self
      def register
        ensure_omml_context
        register_substitutions
      end

      private

      def ensure_omml_context
        return if Lutaml::Model::GlobalContext.context(:uniword)

        Omml::Configuration.register_in(:uniword)
        Lutaml::Model::Config.default_register = :uniword
      end

      def register_substitutions
        register_handle = Lutaml::Model::GlobalRegister.lookup(:uniword)
        return unless register_handle

        SUBSTITUTIONS.each do |omml_class_name, uniword_class_name|
          omml_class = constantize(omml_class_name)
          uniword_class = constantize(uniword_class_name)
          next unless omml_class && uniword_class

          register_handle.register_global_type_substitution(
            from_type: omml_class,
            to_type: uniword_class,
          )
        end
      end

      def constantize(class_name)
        parts = class_name.split("::")
        parts.reduce(Object) do |scope, part|
          scope.const_get(part)
        end
      rescue NameError
        nil
      end
    end
  end
end
