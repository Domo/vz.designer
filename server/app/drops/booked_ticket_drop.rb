class BookedTicketDrop < Liquid::Drop

  def initialize(source)
    @source = source
  end
  
  def name
    @source.assigned_ticket.ticket.name
  end
  
  def total_price
    @source.price
  end
  
  def quantity
    @source.amount
  end

end
