class DItem
  attr_accessor  :line, :context

  def initialize(line, context)
    @line=line
    @context=context
  end
end