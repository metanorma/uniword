# frozen_string_literal: true

# A real visitor that records every visit call, for specs exercising the
# accept/visitor protocol without stubs.
class RecordingVisitor
  attr_reader :visited

  def initialize
    @visited = []
  end

  def visit_math_equation(equation)
    record(:math_equation, equation)
  end

  def visit_image(image)
    record(:image, image)
  end

  def visit_comment(comment)
    record(:comment, comment)
  end

  def visit_comment_range(range)
    record(:comment_range, range)
  end

  private

  def record(kind, element)
    @visited << [kind, element]
  end
end
