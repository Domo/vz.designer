class ErrorDrop < Liquid::Drop
  def initialize(error)
    @error = error
  end
  
  def field
    @error.first
  end
  
  def message
    @error.last
  end  
end