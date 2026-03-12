# frozen_string_literal: true

# DocumentVariables Namespace Autoload Index
# Generated from: config/ooxml/schemas/document_variables.yml
# Total classes: 10

module Uniword
  module DocumentVariables
    # Autoload all DocumentVariables classes
    autoload :DataType, "#{__dir__}/document_variables/data_type"
    autoload :DefaultValue, "#{__dir__}/document_variables/default_value"
    autoload :DocVar, "#{__dir__}/document_variables/doc_var"
    autoload :DocVars, "#{__dir__}/document_variables/doc_vars"
    autoload :ReadOnly, "#{__dir__}/document_variables/read_only"
    autoload :VariableBinding, "#{__dir__}/document_variables/variable_binding"
    autoload :VariableCollection,
             "#{__dir__}/document_variables/variable_collection"
    autoload :VariableExpression,
             "#{__dir__}/document_variables/variable_expression"
    autoload :VariableFormat, "#{__dir__}/document_variables/variable_format"
    autoload :VariableScope, "#{__dir__}/document_variables/variable_scope"
  end
end
