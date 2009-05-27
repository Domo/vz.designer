class RateSearchContainer
	require 'database'
	
	attr_accessor :nights
	
	def initialize()
		@reservation = Database.find(:random, :reservations)
		self.nights =  rand(5) + 1
	end
	
	def arrival_date
		@reservation.arrival_date
	end
	
	def total_price
		@reservation.sell_price
	end
	
	def items
		@reservation.reservation_room_types
	end	
	
	
end