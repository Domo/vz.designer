class ReservationRoomType
	
	def my_name
		"ReservationRoomType"
	end
	
	require 'room_type'
	require 'rate_room_type'
	require 'rate'
	
	require 'database'
	attr_accessor :adults, :children, :reservation_id, :occupancy, :sell_price, :room_type, :rate, :price, :id
	def initialize(_reservation)
		self.room_type = RoomType.new
		self.rate = Rate.new(Database.find(:random, :rates), Rate.options)
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
		RateRoomType.new(Database.find(:random, :rate_room_types))
	end
	
end