# frozen_string_literal: true

require "spec_helper"
require "plurimath"
require "omml"

# Inline OMML equations appended to a paragraph (Omml::Models::CTOMath via
# ParagraphBuilder#<<) must reach the MHTML payload as m:oMath. The omml
# gem models the element's schema TYPE, so a bare CTOMath serializes with
# the root `m:CT_OMath`; Word drops equations carrying that tag in the
# .doc payload. The MHTML renderer renames the root tag at the only place
# that serializes the model directly (the DOCX writer emits oMath through
# the paragraph mapping and was never affected).
RSpec.describe Uniword::Transformation::MhtmlElementRenderer do
  let(:renderer) { described_class.new }

  def paragraph_with_inline_math
    mathml = "<math xmlns=\"http://www.w3.org/1998/Math/MathML\">" \
             "<msub><mi>K</mi><mi>T</mi></msub></math>"
    omml = Plurimath::Mathml::Parser.new(mathml).parse.to_omml
    omath = Omml.parse(omml).o_math.first

    para = Uniword::Builder::ParagraphBuilder.new
    para << "Symbols: "
    para << omath
    para << " end."
    para.build
  end

  it "renders an inline CTOMath as m:oMath in the paragraph HTML" do
    paragraph = paragraph_with_inline_math
    html = renderer.element_to_html(paragraph)

    aggregate_failures do
      expect(html).to include("<m:oMath>")
      expect(html).to include("</m:oMath>")
      expect(html).not_to include("CT_OMath")
    end
  end

  it "leaves oMathPara roots unchanged" do
    mathml = '<math xmlns="http://www.w3.org/1998/Math/MathML"><mi>F</mi></math>'
    omml = Plurimath::Mathml::Parser.new(mathml).parse.to_omml
    omp = Omml.parse(omml)

    expect(renderer.o_math_to_xml_string(omp)).to start_with("<m:oMathPara")
  end
end
