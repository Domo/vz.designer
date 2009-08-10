class TicketBundleDrop < Liquid::Drop
  def initialize(_ticket_bundle)
    @ticket_bundle = _ticket_bundle
    @event = @ticket_bundle.assigned_ticket.event
  end
  
  def weekday
    @ticket_bundle.assigned_ticket.event_availability_time.wday
  end
  
  def event_name
    @ticket_bundle.assigned_ticket.event.name
  end
  
  def event_description
    @ticket_bundle.assigned_ticket.event.description
  end
  
  def location
    @ticket_bundle.assigned_ticket.event.location
  end
   
  def ticket_type
    @ticket_bundle.assigned_ticket.ticket.ticket_type.name
  end
  
  def custom_tag
    return "" if @event.images.length == 0
    '<img src="' + @event.images.first.public_filename('custom') + '" alt="' + @event.name + '"/>' rescue "no custom image."
  end  
  
  def custom_image
    return "" if @event.images.length == 0
    @event.images.first.public_filename('custom') rescue "" 
  end  

  def image_tag
    return "" if @event.images.length == 0
    '<img src="' + @event.images.first.public_filename('normal') + '" alt="' + @event.name + '"/>'
  end    
  
  def image_tags
    text = ""
    for image in @event.images
      text << '<img src="' + image.public_filename('normal') +'" alt="' + @event.name + '" />'
    end
    text
  end  
end
