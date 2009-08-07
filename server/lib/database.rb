require 'yaml'
require 'reservation_room_type'
require 'room_type_image'
require 'rate_room_type'
require 'ticket'

module Database
  
  def self.find(what, table, condition = ["", ""])
  	puts "Database >> find >> " + table.to_s + " >> " + what.to_s + " (" + condition.to_s + ")"
    case what 
    when Numeric
      add_specials(table, db[table.to_s].map { |r| r if r['id'] == what }.compact.first)
    when :all
      add_specials(table, db[table.to_s])
    when :first
      add_specials(table, db[table.to_s].first)
    when :condition
    	add_specials(table, db[table.to_s].map { |r| r if r[condition[0]] == condition[1] }.compact)
    when :random
    	random = rand(db[table.to_s].size)
    	add_specials(table, db[table.to_s][random])
    end
  end
  
  def self.add_specials(_table, _result)
  	case _table.to_sym
		when :rate_room_types
			if _result.is_a?(Hash)
  			_result["room_type"] = self.find(_result["room_type_id"], :room_types)
  		else
  			for rrt in _result
					rrt["room_type"] = self.find(rrt["room_type_id"], :room_types)
				end  
			end
		when :rates
			if _result.is_a?(Hash)
				rate_room_types = self.find(:condition, :rate_room_types, ["rate_id", _result["id"]])
				_result["rate_room_types"] = []
				for rrt in rate_room_types
					_result["rate_room_types"] << RateRoomType.new(rrt)
				end
				_result["images"] = []
				_result["is_ticket_rate"] = false
			else
				for rate in _result
					rate_room_types = self.find(:condition, :rate_room_types, ["rate_id", rate["id"]])
					rate["rate_room_types"] = []
					for rrt in rate_room_types
						rate["rate_room_types"] << RateRoomType.new(rrt)
						rate["images"] = []
					end
					rate["is_ticket_rate"] = false
				end  
			end
		when :reservations
			if _result.is_a?(Hash)
				rooms = []
				(rand(2)+1).times do
					rooms << ReservationRoomType.new(_result.to_mod)
				end
				_result["reservation_room_types"] = rooms
			else
				for reservation in _result
					rooms = []
					(rand(2)+1).times do
						rooms << ReservationRoomType.new(_result.to_mod)
					end
					reservation["reservation_room_types"] = rooms
				end  
			end
		when :room_types
			if _result.is_a?(Hash)
				_result["images"] = []
			else
				for rt in _result
					rt["images"] = []
				end  
			end
		when :properties
			if _result.is_a?(Hash)
				_result["images"] = []
			else
				for prop in _result
						prop["images"] = []
				end
			end
		when :events
			if _result.is_a?(Hash)
				_result["images"] = []
				_result["max_tickets"] = rand(10)+5
			else
				for ev in _result
						ev["images"] = []
						ev["max_tickets"] = rand(10)+5
				end
			end
		when :customers
			if _result.is_a?(Hash)
				c = self.find(:random, :contacts)
				_result["main_contact"] = c
				_result["email"] = c.email
				_result["fullname"] = c.first_name + " " + c.last_name
			else
				for ev in _result
						c = self.find(:random, :contacts)
						ev["main_contact"] = c
						ev["email"] = c.email
						ev["fullname"] = c.first_name + " " + c.last_name
				end
			end
  	end
  	
  	if _result.is_a?(Hash)
  		_result["my_name"] = 'Database => ' + _table.to_s
  		return _result.to_mod
  	else
  		puts 'mapping table ' + _table.to_s
  		for r in _result
  			r["my_name"] = 'Database => ' + _table.to_s
  		end
  		return _result.map { |r| r.to_mod }
		end
		
	end
  
  def self.db
  	db_files = ["database.yml"]
  	for dbf in db_files
  		c = YAML::load_file("#{ROOT}/db/" + dbf)
		end
		return c
  end
  
end