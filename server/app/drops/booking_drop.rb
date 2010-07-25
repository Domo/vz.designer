require 'database'
require 'poll_answer_drop'
require 'event_availability_drop'

class BookingDrop < Liquid::Drop
  def initialize(_booking, _property, _event_property = nil)
    @booking = _booking
    @property = _property
    @event_property = nil
    @event_property = Property.find(_event_property) if not _event_property.nil?
    @selected_golf_course = 0
  end

  def select_golf_course(id)
    @selected_golf_course = id
  end
  
  def errors
    @booking.errors
  end

  def id
    @booking.id
  end

  #deprecated, but might be used in some templates anyway
  def day
    @booking.date.to_date
  end

  def time
    EventAvailabilityTimeDrop.new(EventAvailabilityTime.find(@booking.pa_selected), @booking.date.to_date)
  end

  def event
      EventDrop.new(Database.find(:random, :events))
  end

  def event_availability
    EventAvailabilityDrop.new(@booking.event_availability)
  end

  def payment_due_to
    event = EventAvailabilityTime.find(@booking.pa_selected).event_availability.event
    if event.payment_within > 0 and @booking.payment_type == "cheque"
      return Date.today + event.payment_within
    end
    return Date.today
  end
  
  def payment_within
	  EventAvailabilityTime.find(@booking.pa_selected).event_availability.event.payment_within.to_s
  end

  def payment_type
    @booking.payment_type
  end

  def golf_course
    event
  end

  def date
    @booking.date.to_date
  end

  def tickets
    @booking.booked_tickets.collect{|x| TicketDrop.new(x)}
  end

  def golf_select_options
    options = ""
    e = nil
    e = Event.find(:all, :conditions => ["property_id=? AND type='GolfCourse'", @event_property.id]) if not @event_property.nil?    
    e = Event.all if @event_property.nil?
    selected = ''
    for event in e
      selected = ' selected="selected" ' if event.id == @selected_golf_course
      options << '<option value="' + event.id.to_s + '" ' + selected + '>' + event.name + '</option>'
      selected = ''
    end
    options
  end
  
  def event_select_options
    options = ""
    e = Database.find(:all, :events)
		e.sort!{|x,y| x.name <=> y.name}
    e = e.collect{|x| x if x.show_on_front}.compact
    for event in e
      options << '<option value="' + event.id.to_s + '">' + event.name + '</option>'
    end
    options
  end
  
  def requested_tickets
    @booking.assigned_tickets.collect{|x| AssignedTicketDrop.new(x)}
    list = []
    for assigned_ticket in @booking.assigned_tickets
      list << AssignedTicketDrop.new(assigned_ticket[0], assigned_ticket[1])
    end
    list
  end

  def extras
    list = []
    for be in @booking.booked_extras
      list << BookingExtraDrop.new(be)
    end
    list
  end

  def requested_extras
    list = []
    for extra in @booking.extras
      return if not extra[1]
      list << ExtraDrop.new(Extra.find(extra[0]))
    end
    list
  end

  def booked_tickets
    @booking.booked_tickets.collect{|x| BookedTicketDrop.new(x)}
  end
  
  def total_price
    @booking.total_price
  end
  
  def booking_fee
    @booking.booking_fee
  end  
  
  def format_calendar
    @booking.format_calendar
  end
  
  def reference_number
    @booking.id
  end
  
  def customer
    CustomerDrop.new(@booking.customer)
  end
  
  def golf_times
    return nil if @booking.class.to_s != "GolfBooking"
    list = []
    for bt in @booking.booked_tickets
      list << GolfTimeDrop.new(bt.assigned_ticket.event_availability_time, bt.assigned_ticket.ticket.name.split(" ")[0])
    end
    list
  end
  
  def terms_and_conditions
		terms = @booking.event_availability.event.terms_and_conditions
		  terms = CustomerSetting.first.terms_conditions if terms.blank?
		terms
  end

  def booked_at
    @booking.created_on
  end
  
  def deposit_charged?
  	(not @booking.total_price == @booking.get_charged_price)
	end
	
	def deposit
		@booking.get_charged_price
	end
	
	def open_payment_amount
		@booking.open_payment_amount
	end
	
	def questions
	 	q = []
		unless @booking.questions.empty?
      q = @booking.questions.map {|p| PollAnswerDrop.new(p)}
    end
	end	
	
	def has_questions
		@booking.has_questions
	end

  private
    def events
      settings = WebReservationSetting.find(:first, :conditions => ["property_id=? and is_hidden=0", @property.id])
      properties = []
      properties << @property
      
      #create containers for every assigned property and append them to containers list
      for wrs in settings.web_reservation_properties  
        properties << wrs.property
      end
      
      event_rates = Rate.properties_event_rates(properties)
      event_rates.compact!
      
      events = {}
      for rate in event_rates
        events[rate.assigned_event] = [] if events[rate.assigned_event].nil?
        events[rate.assigned_event] << rate.first_day_of_event
      end
     
      #sort that stuff
      events = events.sort{|a,b| a[1] <=> b[1]}
      events
    end
end
