class ReservationRoomType
	require 'database'
	attr_accessor :adults, :children, :reservation_id, :occupancy, :sell_price, :room_type, :rate
	def initialize(_reservation)
		self.adults = rand(4) + 1
		self.children = rand(2) + 1
		self.reservation_id = _reservation.id
		self.occupancy = self.adults + self.children
		self.sell_price = 50
		self.room_type = Database.find(:random, :room_types)
		self.rate = Database.find(:random, :rates)
	end
	
	def property_room_type
		{:room_type => self.room_type}.to_mod
	end
	
end