class RateSearchContainer
	require 'database'
	
	def my_name
		"RateSearchContainer"
	end
	
	attr_accessor :nights, :property
	
	def initialize(_property = nil)
		@reservation = Database.find(:random, :reservations)
		@property = _property
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

end