class CreditcardDrop < Liquid::Drop
	
	def initialize()
		
	end
	
	def options_for_months
		i = 1
		tag = ""
		12.times do
			tag << '<option value="' + i.to_s + '">' + i.to_s + '</option>'
			i += 1
		end
		return tag
	end
	
	def options_for_years
		i = Time.now.year
		tag = ""
		5.times do
			tag << '<option value="' + i.to_s + '">' + i.to_s + '</option>'
			i += 1
		end
		return tag
	end
	
end