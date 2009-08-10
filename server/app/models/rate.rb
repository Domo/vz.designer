class Rate
	
	require 'event_availability'
	require 'rate_room_type'
	require 'room_type_image'
	require 'ticketbundle'
	require 'database'
	
	cattr_accessor :options
	
	def my_name
		"Rate"
	end
	
	def initialize(_rate, _options)
		@rate = _rate
		@options = _options
	end
	
	def id
		@rate.id
	end
	
	def code
		@rate.code
	end
	
	def name
		@rate.name
	end
	
	def description
		@rate.description
	end
	
	def property_id
		@rate.property_id
	end	
	
	def rate_room_types
		Database.find(:condition, :rate_room_types, ["rate_id", self.id]).map {|x| RateRoomType.new(x)}
	end
	
	def images
		if @options.include? "show_rate_images"
			return [RoomTypeImage.new("rate")]
		end
		[]
	end
	
	def is_ticket_rate?
		if @options.include? "rates_are_ticket_rates"
			return true
		end
		false
	end
	
	def ticketbundles
		[Ticketbundle.new(self)]
	end
	
	def assigned_events_names
		Database.find(:random, :events).name
	end

end