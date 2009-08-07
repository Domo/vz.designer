class EventAvailabilityTime
	
	require 'event_availability'
	
	def my_name
		"EventAvailabilityTime"
	end
	
	require 'database'
	
	attr_accessor :id, :event_availability
	
	def initialize(_options = [])
		self.id = rand(100) + 1
		self.event_availability = EventAvailability.new
		@options = _options
	end
	
	def website_discount
		if @options.include? "show_website_discount"
			return rand(3)+1
		end
		return 0		
	end
	
	def flat_price
		rand(50) + 1
	end
	
	def requested_quantity
		rand(5) + 1
	end
	
	def starttime
		t = Time.now + (rand(20)+1)*3600
		t.strftime("%H:%m")
	end
	
end