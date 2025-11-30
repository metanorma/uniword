# frozen_string_literal: true

# DocumentVariables Namespace Autoload Index
# Generated from: config/ooxml/schemas/document_variables.yml
# Total classes: 10

module Uniword
  module DocumentVariables
    # Autoload all DocumentVariables classes
    autoload :DataType, File.expand_path('document_variables/data_type', __dir__)
    autoload :DefaultValue, File.expand_path('document_variables/default_value', __dir__)
    autoload :DocVar, File.expand_path('document_variables/doc_var', __dir__)
    autoload :DocVars, File.expand_path('document_variables/doc_vars', __dir__)
    autoload :ReadOnly, File.expand_path('document_variables/read_only', __dir__)
    autoload :VariableBinding, File.expand_path('document_variables/variable_binding', __dir__)
    autoload :VariableCollection,
             File.expand_path('document_variables/variable_collection', __dir__)
    autoload :VariableExpression,
             File.expand_path('document_variables/variable_expression', __dir__)
    autoload :VariableFormat, File.expand_path('document_variables/variable_format', __dir__)
    autoload :VariableScope, File.expand_path('document_variables/variable_scope', __dir__)
  end
end
