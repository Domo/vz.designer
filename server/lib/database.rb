require 'yaml'

module Database
  
  def self.find(what, table, condition = '')
    case what 
    when Numeric
    	puts 'database: find: numeric => ' + what.to_s
      add_specials(table, db[table.to_s].map { |r| r if r['id'] == what }.compact.first)
    when :all
      add_specials(table, db[table.to_s])
    when :first
      # db[table.to_s].find { |a| a['id'] == 1 } 
      add_specials(table, db[table.to_s].first)
    when :condition
    	cond1 = condition.split("=").first
    	cond2 = condition.split("=").last
    	cond2 = cond2.to_i if cond2.is_a?(Numeric)
    	add_specials(table, db[table.to_s].map { |r| r if r['cond1'] == cond2 }.compact)
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