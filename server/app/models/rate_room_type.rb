class RateRoomType
	
	attr_accessor :room_type, :id, :total
	
	def my_name
		"RateRoomType"
	end
	
	def initialize(_rate_room_type)
		@rate_room_type = _rate_room_type
		
		self.room_type = @rate_room_type.room_type
		self.id = @rate_room_type.id
	end
	
	
	def days(_rate_search_container)
		days = []
		self.total = 0
		i = 1
		7.times do
			day = {}
			day["is_available"] = rand(2) == 1 ? true : false
			day["price_for_day"] = rand(50)+1
			day["part_of_request"] = i <= _rate_search_container.nights ? true : false
			self.total += day["price_for_day"] if day["part_of_request"] and day["is_available"]
			days << day.to_mod
			i += 1
		end	
		return days
	end
	
	def has_prices_for_period(_rate_search_container)
		true
	end
	
	def sum_days_for_period(_rate_search_container)
		self.total
	end
end