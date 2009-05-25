class ReservationRoomType
	require 'database'
	attr_accessor :adults, :children, :reservation_id, :occupancy, :sell_price
	def initialize(_reservation)
		self.adults = rand(4)
		self.children = rand(2)
		self.reservation_id = _reservation.id
		self.occupancy = self.adults + self.children
		self.sell_price = 50
	end
	
	def property_room_type
		{:room_type => Database.find(:random, :room_types)}.to_mod
	end
end