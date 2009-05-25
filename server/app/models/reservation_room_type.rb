class ReservationRoomType
	require 'database'
	attr_accessor :adults, :children, :reservation_id, :occupancy, :sell_price, :room_type, :rate
	def initialize(_reservation)
		self.room_type = Database.find(:random, :room_types)
		self.rate = Database.find(:random, :rates)
		self.adults = rand(self.room_type.adults) + self.room_type.min_adults
		self.children = (rand(self.room_type.max_children) + self.room_type.children).to_i
		self.reservation_id = _reservation.id
		self.occupancy = self.adults + self.children
		self.sell_price = 50
	end
	
	def property_room_type
		{:room_type => self.room_type}.to_mod
	end
	
end