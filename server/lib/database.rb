require 'yaml'
require 'reservation_room_type'

module Database
  
  def self.find(what, table, condition = '')
    case what 
    when Numeric
    	puts 'database >> find >> numeric => ' + what.to_s
      add_specials(table, db[table.to_s].map { |r| r if r['id'] == what }.compact.first)
    when :all
      add_specials(table, db[table.to_s])
    when :first
      add_specials(table, db[table.to_s].first)
    when :condition
    	cond1 = condition.split("=").first
    	cond2 = condition.split("=").last
    	cond2 = cond2.to_i if cond2.to_i.to_s == cond2
    	puts "database >> find >> condition => " + condition
    	add_specials(table, db[table.to_s].map { |r| r if r['cond1'] == cond2 }.compact)
    when :random
    	random = rand(db[table.to_s].size)
    	add_specials(table, db[table.to_s][random])
    end
  end
  
  def self.add_specials(_table, _result)
  	case _table
		when :rate_room_types
			if _result.is_a?(Hash)
  			_result["room_type"] = self.find(_result["room_type_id"], "room_types")
  		else
  			for rrt in _result
					rrt["room_type"] = self.find(rrt["room_type_id"], "room_types")
				end  
			end
		when :rates
			if _result.is_a?(Hash)
				_result["rate_room_types"] = self.find(:condition, :rate_room_types, "rate_id=" + _result["id"].to_s)
			else
				for rate in _result
					rate["rate_room_types"] = self.find(:condition, :rate_room_types, "rate_id=" + rate["id"].to_s)
				end  
			end
		when :reservations
			if _result.is_a?(Hash)
				_result["reservation_room_types"] = [ReservationRoomType.new(_result.to_mod)]
			else
				for reservation in _result
					reservation["reservation_room_types"] = [ReservationRoomType.new(rate.to_mod)]
				end  
			end
  	end
  	
  	if _result.is_a?(Hash)
  		return _result.to_mod
  	else
  		puts 'mapping table ' + _table.to_s
  		return _result.map { |r| r.to_mod }
		end
		
	end
  
  def self.db
    YAML::load_file("#{ROOT}/db/database.yml")
  end
  
end