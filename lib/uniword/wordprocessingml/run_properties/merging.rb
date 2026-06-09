# frozen_string_literal: true

module Uniword
  module Wordprocessingml
    class RunProperties < Lutaml::Model::Serializable
      # Merge semantics for RunProperties.
      #
      # Provides style-inheritance merging where override properties take
      # precedence over base properties. Uses the model's declared attributes
      # via read_attribute/write_attribute — fully model-driven.
      module Merging
        # Merge with another RunProperties, using self as override.
        #
        # For each declared attribute: if self has a non-default value,
        # use it; otherwise use the other's value.
        #
        # @param base [RunProperties] Base (inherited) properties
        # @return [RunProperties] New merged properties
        def merged_over(base)
          merged = RunProperties.new

          self.class.attributes.each_key do |attr_name|
            override_val = read_attribute(attr_name)
            base_val = base.read_attribute(attr_name)

            use_override = if override_val.is_a?(Lutaml::Model::Serializable)
                             override_val.class.attributes.any? do |k, _|
                               !override_val.using_default?(k)
                             end
                           else
                             !override_val.nil?
                           end

            value = use_override ? override_val : base_val
            next unless value

            merged.write_attribute(attr_name, value)
          end

          merged
        end
      end
    end
  end
end
