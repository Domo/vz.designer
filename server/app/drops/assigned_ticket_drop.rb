class AssignedTicketDrop < Liquid::Drop

  def initialize(source, quantity=0)
    @source = source
    @quantity = quantity
  end
  
  def event_availability_time_id
    @source.event_availability_time.id
  end
  
  def name
    @source.ticket.ticket_type.name
  end
  
  def time_id
    @source.event_availability_time.id
  end
  
  def price
    @source.ticket.price
  end
  
  def quantity
    @quantity
  end
  
  def full_ticket_information
    t = "ticket"
    t = "tickets" if @quantity > 1
    @quantity.to_s + " " + name + " " + t
  end

  def ticket_select_options
    options = '<select id="ticket_' + @source.event_availability_time.id.to_s + '" name="ticket[' + @source.id.to_s + ']" onchange="updatePrice(this)" class="ticket_' + @source.event_availability_time.id.to_s + '_ticketselector" title="' + price.to_s + '">'
    max = 5
    max = @source.event_availability.event.max_tickets if @source.event_availability.event.max_tickets > 0
    for x in (0..max)
      options << '<option value="' + x.to_s + '">' + x.to_s + '</option>'
    end
    options << "</select>"
    options
  end  
  
  def total_price
    @source.ticket.price * quantity    
  end
  
  def short_description
    @source.ticket.ticket_type.short_description
  end

  def description
    @source.ticket.ticket_type.description
  end
end
