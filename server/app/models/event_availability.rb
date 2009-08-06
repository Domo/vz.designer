class EventAvailability
	
	def my_name
		"EventAvailability"
	end
	
	require 'database'
	
	attr_accessor :id, :db, :event
	
	def initialize()
		self.id = rand(100) + 1
		self.db = Database.find(:random, :event_availabilities)
		self.event = Database.find(:random, :events)
	end
	
	def name
		self.db.name
	end

	
end