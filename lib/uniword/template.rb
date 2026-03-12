# frozen_string_literal: true

module Uniword
  module Template
    autoload :Template, "#{__dir__}/template/template"
    autoload :VariableResolver, "#{__dir__}/template/variable_resolver"
    autoload :TemplateParser, "#{__dir__}/template/template_parser"
    autoload :TemplateRenderer, "#{__dir__}/template/template_renderer"
    autoload :TemplateValidator, "#{__dir__}/template/template_validator"
    autoload :TemplateContext, "#{__dir__}/template/template_context"
    autoload :TemplateMarker, "#{__dir__}/template/template_marker"
    autoload :Helpers, "#{__dir__}/template/helpers"
  end
end
