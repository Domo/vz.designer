class ReservationRoomType
	
	def my_name
		"ReservationRoomType"
	end
	
	require 'database'
	attr_accessor :adults, :children, :reservation_id, :occupancy, :sell_price, :room_type, :rate, :price, :id
	def initialize(_reservation)
		self.room_type = Database.find(:random, :room_types)
		self.rate = Database.find(:random, :rates)
		self.adults = (rand(self.room_type.adults) + self.room_type.min_adults).to_i
		self.adults = self.adults + 1 if self.adults == 0
		self.children = (rand(self.room_type.max_children) + self.room_type.children).to_i
		self.reservation_id = _reservation.id
		self.occupancy = self.adults + self.children
		self.sell_price = rand(75) + 1
		self.price = self.sell_price
		self.id = self.room_type.id
	end
	
	def property_room_type
		{:room_type => self.room_type}.to_mod
	end
	
	def rate_room_type
		self.property_room_type
	end
	
end