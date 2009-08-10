class RoomType
	require 'database'
	require 'rate'
		
	
	def my_name
		"RoomType"
	end
	
	attr_accessor :images, :rate
	
	def initialize()
		@rt = Database.find(:random, :room_types)
		self.images = []
		self.rate = Rate.new(Database.find(:random, :rates), Rate.options)
	end

	def id
		@rt.id
	end
	
	def name
		@rt.name
	end
	
	def adults
		@rt.adults
	end
	
	def children
		@rt.children
	end
	
	def min_adults
		@rt.min_adults
	end
	
	def max_children
		@rt.max_children
	end
	
	def description
		@rt.description
	end
	
	def short_description
		@rt.short_description
	end
	
	def code
		@rt.code
	end
	
	def type
		@rt.type
	end
end