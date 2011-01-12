require 'yaml'
require 'reservation_room_type'
require 'room_type_image'
require 'rate_room_type'
require 'rate'
require 'ticket'
require "wsession"

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
		when :polls
			if _result.is_a?(Hash)
				_result["answers"] = ["Answer 1", "Answer 2", "Answer 3"] if poll["answer_type"] == "dropdown"
			else
				for poll in _result
						if poll["answer_type"] == "dropdown"
							poll["answers"] = ["Answer 1", "Answer 2", "Answer 3"]
						end
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
		when :vouchers
		  if _result.is_a?(Hash)
        _result["images"] = []
      else
        for rec in _result
            rec["images"] = []
        end
      end
  	end
  	
  	if _result.is_a?(Hash)
  		_result["my_name"] = 'Database => ' + _table.to_s
  		if WSession.options && WSession.options.include?("records_have_errors")
  		  _result["errors"] = [["field_with_error", "I am a validation error :)"]]
  		else
  		  _result["errors"] = []
  		end
  		return _result.to_mod
  	else
  		puts 'mapping table ' + _table.to_s
  		for r in _result
  		  if WSession.options && WSession.options.include?("records_have_errors")
  		    r["errors"] = [["field_with_error", "I am a validation error :)"]]
  		  else
  		    r["errors"] = []
  		  end
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
