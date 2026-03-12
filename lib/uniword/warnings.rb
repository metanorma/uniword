# frozen_string_literal: true

module Uniword
  module Warnings
    autoload :Warning, "#{__dir__}/warnings/warning"
    autoload :WarningCollector, "#{__dir__}/warnings/warning_collector"
    autoload :WarningReport, "#{__dir__}/warnings/warning_report"
  end
end
