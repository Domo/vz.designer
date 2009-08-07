class Ticket
	
	require 'event_availability_time'
	require 'event_availability'	
	
	def my_name
		"Ticket"
	end
	
	require 'database'
	
	attr_accessor :ticket_type, :event_availability_time, :event_availability, :event, :id, :price
	
	def initialize(_event_availability_time = nil)
		self.ticket_type = Database.find(:random, :ticket_types)
		self.event_availability = EventAvailability.new
		self.event_availability_time = _event_availability_time
		self.event_availability_time = EventAvailabilityTime.new unless self.event_availability_time
		self.event = Database.find(:random, :events)
		self.id = rand(50) + 1
		self.price = rand(50) + 1
	end

	def ticket
		self
	end
	
end