class EventAvailability

	def my_name
		"EventAvailability"
	end
	
	require 'database'
	require "wsession"
	
	attr_accessor :id, :db, :event
	
	def initialize()
		self.id = rand(100) + 1
		self.db = Database.find(:random, :event_availabilities)
		self.event = Database.find(:random, :events)
	end
	
	def name
		self.db.name
	end
	
	def polls
		q = []
		if WSession.options.include? "booking_has_questions"
			q = Database.find(:all, :polls)
		end
		
		return q
	end

	
end
