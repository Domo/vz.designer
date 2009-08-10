class CustomerSetting

	def my_name
		"CustomerSetting"
	end
	
	def initialize()
	end
		
	def terms_conditions
		"These are example terms and conditions which are not event specific."
	end 
	
	def booking_fee
		b = rand(3)
		return false if b = 0
		b
	end
	
end