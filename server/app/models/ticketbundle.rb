class Ticketbundle
	require 'database'
	require 'ticket'
	require 'servlet'
	
	def my_name
		"Ticketbundle"
	end
	
	attr_accessor :id, :assigned_ticket, :rate, :special_price, :event
	
	def initialize(_rate)
		self.id = rand(100)+1
		self.assigned_ticket = Ticket.new
		self.rate = _rate
		self.special_price = rand(10)+1
		self.event = Database.find(:random, :events)
	end
	
	def applies_for_day? day
		return true
	end
	
	
end