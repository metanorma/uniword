# frozen_string_literal: true

module Uniword
  # Plugin system: extend uniword without forking.
  #
  # Three extension surfaces, each with a base class:
  #
  # - `Plugin::Validator` — register custom validation rules
  # - `Plugin::Transformer` — mutate documents at defined pipeline
  #   stages (load, pre-save, post-reconcile)
  # - `Plugin::CliCommand` — register new Thor subcommands
  #
  # Discovery: `Plugin::Loader.load_all` walks installed gems via
  # `Gem.find_files("uniword/plugin/*.rb")` and loads each.
  #
  # Configuration: `Uniword.configuration.plugins = [:my_plugin]`
  # (default `:all`).
  module Plugin
    autoload :Registry, "#{__dir__}/plugin/registry"
    autoload :Validator, "#{__dir__}/plugin/validator"
    autoload :Transformer, "#{__dir__}/plugin/transformer"
    autoload :CliCommand, "#{__dir__}/plugin/cli_command"
    autoload :Loader, "#{__dir__}/plugin/loader"
  end
end
