# frozen_string_literal: true

module Uniword
  module Properties
    # Run-level boolean formatting elements
    BooleanElementFactory.define("strike", "Strike")
    BooleanElementFactory.define("dstrike", "DoubleStrike")
    BooleanElementFactory.define("smallCaps", "SmallCaps")
    BooleanElementFactory.define("caps", "Caps")
    BooleanElementFactory.define("vanish", "Vanish")
    BooleanElementFactory.define("webHidden", "WebHidden")
    BooleanElementFactory.define("noProof", "NoProof")
    BooleanElementFactory.define("shadow", "Shadow")
    BooleanElementFactory.define("emboss", "Emboss")
    BooleanElementFactory.define("imprint", "Imprint")

    # Style-level boolean elements
    BooleanElementFactory.define("qFormat", "QuickFormat")
    BooleanElementFactory.define("keepNext", "KeepNext")
    BooleanElementFactory.define("keepLines", "KeepLines")

    # Paragraph-level boolean elements
    BooleanElementFactory.define("suppressLineNumbers", "SuppressLineNumbers")
    BooleanElementFactory.define("bidi", "Bidi")
  end
end
