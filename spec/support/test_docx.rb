# frozen_string_literal: true

# Builds real minimal DOCX files for specs, so DocumentFactory loads
# genuine documents instead of stubbed ones.
module TestDocx
  module_function

  def write(path, text: "Component content with {title}")
    FileUtils.mkdir_p(File.dirname(path))
    builder = Uniword::Builder::DocumentBuilder.new
    builder.paragraph(text)
    builder.build.save(path)
    path
  end
end
