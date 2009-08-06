class EventAvailabilityTimeDrop < Liquid::Drop
	
	require 'assigned_ticket_drop'
	require 'ticket'

  def initialize(source, date)
  	#Source is an event availability time
    @source = source
    @date = date
  end

  def name
    @source.event_availability.name
  end
  
  def description
    @source.event_availability.event.description
  end  
  
  def short_description
    @source.event_availability.short_description
  end  
  
  def id
    @source.id
  end
  
  def weekday
    @source.weekday
  end
  
  def event
    @source.event_availability.event
  end

  def event_id
    @source.event_availability.event.id
  end
  
  def ticket_price
    @source.flat_price
  end
  
  def tickets_price
    @source.flat_price * @source.requested_quantity
  end
  
  def contains_website_discount
    @source.website_discount > 0
  end
  
  def website_discount_price
    (@source.website_discount*0.01) * tickets_price
  end
  
  def website_discount
    @source.website_discount
  end
  
  def time_frame
    @source.starttime.to_s
  end
  
  def time
    time_frame
  end

  def available_tickets
    a = @source.available_tickets_for_day(@date)
    return 0 if a <= 0
    return a
  end

  def booking_fee
    @source.event_availability.booking_fee
  end
  
  def total_cost
    #((@source.flat_price * @source.requested_quantity) * (1 - @source.website_discount*0.01)) + @source.booking_fee
  end
  
  def questions
    @questions = []
    if not @source.pools.nil? && @source.pools.length > 0
      for question in @source.pools
        @questions << PoolDrop.new(question)
      end
    end  
    @questions
  end

  def tickets
    assigned_tickets   
  end

  def has_tickets
    assigned_tickets.length > 0
  end

  def extras
    @source.event_availability.bookable_extras(@date).collect{|x| ExtraDrop.new(x)}
  end
  
  private
    def assigned_tickets
      return @assigned_tickets if not @assigned_tickets.nil?
      @assigned_tickets = []
      (rand(3)+1).times do
      	@assigned_tickets << AssignedTicketDrop.new(Ticket.new(@source))
      end
      return @assigned_tickets
    end

end
