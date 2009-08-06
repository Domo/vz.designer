class Booking
	
	def my_name
		"Booking"
	end
	
	require 'database'
	
	attr_accessor :date, :id, :payment_type

	def initialize()
		self.date = Time.random.to_us_date
		self.id = rand(100) + 1
		self.payment_type = 'cc'
	end
	
	def event_selected
		Database.find(:random, :events).id
	end
	
end