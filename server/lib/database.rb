require 'yaml'

module Database
  
  def self.find(what, table, condition = '')
    case what 
    when Numeric
      db[table.to_s].map { |r| r if r['id'] == what }.first.to_mod
    when :all
      db[table.to_s].map {|i| i.to_mod }
    when :first
      # db[table.to_s].find { |a| a['id'] == 1 } 
      db[table.to_s].first.to_mod
    when :condition
    	cond1 = condition.split("=").first
    	cond2 = condition.split("=").last
    	db[table.to_s].map { |r| r['cond1'] == cond2 }
    end
  end
  
  def self.db
    YAML::load_file("#{ROOT}/db/database.yml")
  end
  
end