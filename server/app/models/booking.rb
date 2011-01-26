class Booking
	
	require "wsession"
	
	def my_name
		"Booking"
	end
	
	require 'database'
	require 'event_availability'
	
	attr_accessor :date, :id, :payment_type, :assigned_tickets, :total_price, :created_on, :deposit_amount, :event_availability

	def initialize()
		self.date = Time.random.to_us_date
		self.id = rand(100) + 1
		self.payment_type = 'cc'
		self.assigned_tickets = []
		self.total_price = 0
		(rand(3)+1).times do
			t = Ticket.new
			q = rand(3)+1
			self.assigned_tickets << [t, q]
			self.total_price += t.price * q
		end
		self.deposit_amount = self.total_price - (rand(self.total_price.to_i-5)+1)
		self.created_on = Time.random
		self.event_availability = EventAvailability.new
	end
	
	
	def event_selected
		Database.find(:random, :events).id
	end
	
	def format_calendar
    text = '<div id="event_calendar_wrapper">'
    text += navigation_for_calendar
    text += '<table id="calendar_overview" border="0" cellspacing="0" cellpadding="0">'
    text += table_headers_for_calendar
    
    text += days_for_calendar
    
    text += '</table>'
    
    text += "</div>"
    return text
  end  
  
  def days_for_calendar
  	text = "<tbody>"
  	i = 1
  		4.times do
  			text += "<tr>"
  			7.times do
  				text += '<td class="day">'
  				if rand(2) == 1
  					text += '<div class="day-title clearfix">' + i.to_s + '</div>'
  					text += "<a href='/search_tickets' class='ticket_available'>Book Now</a>"
					else
						text += '<div class="cal-no-event">&nbsp;</div>'
						text += '<div class="day-title clearfix">' + i.to_s + '</div>'
					end
					text += "</td>"
					i += 1
				end
				text += "</tr>"
			end
  	text += "</tbody>"
  end
  
  def navigation_for_calendar
  	'<div id="nav_menu" class="clearfix"><div id="nav_menu"><div id="nav_menu_aux"<div id="prev_month"><a href="#">&lt; Prev</a></div><div id="date">September, 2009</div><div id="next_month"><a href="#">Next &gt;</a></div></div></div></div>'
	end
	
	def table_headers_for_calendar
		"<thead><tr class='weekdays head-days'><th>Mon</th><th>Tue</th><th>Wed</th><th>Thu</th><th>Fri</th><th>Sat</th><th>Sun</th></tr></thead>"
	end
	
	def get_charged_price
		if WSession.options.include? "deposit_charged"
			return self.deposit_amount
		end
		return self.total_price
	end
	
	def deposit
		@booking.get_charged_price
	end
	
	def open_payment_amount
		self.total_price - self.deposit
	end
	
	def questions
		q = []
		if WSession.options.include? "booking_has_questions"
			q << {:question => "test question 1", :answer => "test answer 1"}
			q << {:question => "test question 2", :answer => "test answer 2"}
		end
		
		return q
	end	
	
	def has_questions
		(not questions.empty?)
	end	
end
