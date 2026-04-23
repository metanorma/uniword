# frozen_string_literal: true

# Math namespace module
# This file explicitly autoloads all Math classes
# Using explicit autoload instead of dynamic Dir[] for maintainability
#
# Office Math Markup Language (OMML) support for equations
# Auto-generated index file for Math namespace classes

module Uniword
  module Math
    # Simple value classes (9)
    autoload :BeginChar, "uniword/math/begin_char"
    autoload :EndChar, "uniword/math/end_char"
    autoload :SeparatorChar, "uniword/math/separator_char"
    autoload :Char, "uniword/math/char"
    autoload :MathText, "uniword/math/math_text"
    autoload :MathBreak, "uniword/math/math_break"
    autoload :MathFont, "uniword/math/math_font"
    autoload :MathStyle, "uniword/math/math_style"
    autoload :Element, "uniword/math/element"

    # Property classes (26)
    autoload :ArgumentProperties, "uniword/math/argument_properties"
    autoload :ControlProperties, "uniword/math/control_properties"
    autoload :OMathParaProperties, "uniword/math/o_math_para_properties"
    autoload :FractionProperties, "uniword/math/fraction_properties"
    autoload :FunctionProperties, "uniword/math/function_properties"
    autoload :DelimiterProperties, "uniword/math/delimiter_properties"
    autoload :EquationArrayProperties, "uniword/math/equation_array_properties"
    autoload :MatrixColumnProperties, "uniword/math/matrix_column_properties"
    autoload :MatrixColumn, "uniword/math/matrix_column"
    autoload :MatrixColumns, "uniword/math/matrix_columns"
    autoload :MatrixProperties, "uniword/math/matrix_properties"
    autoload :SubscriptProperties, "uniword/math/subscript_properties"
    autoload :SuperscriptProperties, "uniword/math/superscript_properties"
    autoload :PreSubSuperscriptProperties,
             "uniword/math/pre_sub_superscript_properties"
    autoload :SubSuperscriptProperties,
             "uniword/math/sub_superscript_properties"
    autoload :RadicalProperties, "uniword/math/radical_properties"
    autoload :LowerLimitProperties, "uniword/math/lower_limit_properties"
    autoload :UpperLimitProperties, "uniword/math/upper_limit_properties"
    autoload :GroupCharProperties, "uniword/math/group_char_properties"
    autoload :AccentProperties, "uniword/math/accent_properties"
    autoload :NaryProperties, "uniword/math/nary_properties"
    autoload :MathRunProperties, "uniword/math/math_run_properties"
    autoload :BoxProperties, "uniword/math/box_properties"
    autoload :BarProperties, "uniword/math/bar_properties"
    autoload :BorderBoxProperties, "uniword/math/border_box_properties"
    autoload :PhantomProperties, "uniword/math/phantom_properties"
    autoload :MathProperties, "uniword/math/math_properties"
    autoload :MathSimpleVal, "uniword/math/math_simple_val"
    autoload :MathSimpleIntVal, "uniword/math/math_simple_int_val"

    # Element content classes (9)
    autoload :Numerator, "uniword/math/numerator"
    autoload :Denominator, "uniword/math/denominator"
    autoload :FunctionName, "uniword/math/function_name"
    autoload :Sub, "uniword/math/sub"
    autoload :Sup, "uniword/math/sup"
    autoload :Degree, "uniword/math/degree"
    autoload :Lim, "uniword/math/lim"

    # Structure classes (22)
    autoload :Fraction, "uniword/math/fraction"
    autoload :Function, "uniword/math/function"
    autoload :Delimiter, "uniword/math/delimiter"
    autoload :EquationArray, "uniword/math/equation_array"
    autoload :MatrixRow, "uniword/math/matrix_row"
    autoload :Matrix, "uniword/math/matrix"
    autoload :Subscript, "uniword/math/subscript"
    autoload :Superscript, "uniword/math/superscript"
    autoload :PreSubSuperscript, "uniword/math/pre_sub_superscript"
    autoload :SubSuperscript, "uniword/math/sub_superscript"
    autoload :Radical, "uniword/math/radical"
    autoload :LowerLimit, "uniword/math/lower_limit"
    autoload :UpperLimit, "uniword/math/upper_limit"
    autoload :GroupChar, "uniword/math/group_char"
    autoload :Accent, "uniword/math/accent"
    autoload :Nary, "uniword/math/nary"
    autoload :MathRun, "uniword/math/math_run"
    autoload :Box, "uniword/math/box"
    autoload :Bar, "uniword/math/bar"
    autoload :BorderBox, "uniword/math/border_box"
    autoload :Phantom, "uniword/math/phantom"

    # Root classes (2)
    autoload :OMath, "uniword/math/o_math"
    autoload :OMathPara, "uniword/math/o_math_para"
  end
end
