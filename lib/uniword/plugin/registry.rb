# frozen_string_literal: true

module Uniword
  module Plugin
    # Central registry for installed plugins. Each plugin registers
    # its extension surface (validator, transformer, cli command) by
    # name; lookup is by name or by class.
    #
    # Open/closed: new extension surfaces = new methods on this
    # class. Existing entries untouched.
    class Registry
      @validators = {}
      @transformers = {}
      @cli_commands = {}

      class << self
        # @return [Hash{Symbol => Plugin::Validator}]
        attr_reader :validators

        # @return [Hash{Symbol => Plugin::Transformer}]
        attr_reader :transformers

        # @return [Hash{Symbol => Plugin::CliCommand}]
        attr_reader :cli_commands

        # Register a validator. Append-only; duplicate name raises.
        #
        # @param name [Symbol]
        # @param validator [Plugin::Validator]
        # @return [void]
        def register_validator(name, validator)
          raise ArgumentError, "name must be a Symbol" unless name.is_a?(Symbol)
          unless validator.is_a?(Validator)
            raise ArgumentError,
                  "validator must be a Validator"
          end

          @validators[name] = validator
        end

        # Register a transformer.
        #
        # @param name [Symbol]
        # @param transformer [Plugin::Transformer]
        # @return [void]
        def register_transformer(name, transformer)
          raise ArgumentError, "name must be a Symbol" unless name.is_a?(Symbol)
          unless transformer.is_a?(Transformer)
            raise ArgumentError,
                  "transformer must be a Transformer"
          end

          @transformers[name] = transformer
        end

        # Register a CLI command (a Thor subclass).
        #
        # @param name [Symbol]
        # @param command_class [Class]
        # @return [void]
        def register_cli_command(name, command_class)
          raise ArgumentError, "name must be a Symbol" unless name.is_a?(Symbol)
          unless command_class.is_a?(Class)
            raise ArgumentError,
                  "command_class must be a Class"
          end

          @cli_commands[name] = command_class
        end

        # Clear every registry. Used between tests and by
        # `Configuration#reset!`.
        #
        # @return [void]
        def clear
          @validators.clear
          @transformers.clear
          @cli_commands.clear
        end
      end
    end
  end
end
