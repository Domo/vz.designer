class RateSearchContainer
	require 'database'
	require 'rate'
	require 'servlet'
	require "wsession"
	
	def my_name
		"RateSearchContainer"
	end
	
	attr_accessor :nights, :property, :options
	
	def initialize(_property = nil, _options = nil)
		@reservation = Database.find(:random, :reservations)
		@property = _property
		@options = _options
		self.options = @options
		self.property = _property
		self.nights =  rand(5) + 1
	end
	
	def arrival_date
		a = @reservation.arrival_date
		d = a.split(".")
		return d[2] + '-' + d[1] + '-' + d[0]
	end
	
	def total_price
		@reservation.sell_price
	end
	
	def items
		@reservation.reservation_room_types
	end	
	
	def adults
		@reservation.adults
	end
	
	def children
		@reservation.children
	end

	def charged_price
		@reservation.paid
	end
	
	def rates
		rates = Database.find(:condition, :rates, ["property_id", @property.id]).map {|r| Rate.new(r, @options)}
	end
	
	def questions
		q = []
		if WSession.options.include? "booking_has_questions"
			q = Database.find(:all, :polls)
		end
		
		return q
	end
	
	def has_questions
		(not questions.empty?)
	end

end
