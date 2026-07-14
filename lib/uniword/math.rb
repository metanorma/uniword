# frozen_string_literal: true

# Namespace for math-related helpers. OMML schema models were removed in
# favor of the omml gem; only the Plurimath adapter remains.
module Uniword
  module Math
    autoload :PlurimathAdapter, "uniword/math/plurimath_adapter"
  end
end
