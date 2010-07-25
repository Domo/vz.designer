class PollAnswerDrop < Liquid::Drop
  def initialize(source)
    @poll = source
  end
  
  def question
    @poll[:question]
  end
  
  def answer
    @poll[:answer]
  end
end