class RateSearchDrop < Liquid::Drop
	require 'database'
	
	def my_name
		"RateSearchDrop"
	end
	
  def initialize(_property, _rate_search_container)
    @property = _property
    @db_rates = Database.find(:condition, :rates, ["property_id", @property.id])
    @rate_search_container = _rate_search_container
  end  
  
  #get list of RateDrops
  def items
    @rate_search_container.items.collect { |x| RateSearchContainerItemDrop.new(x) }
  end
  
  def position
    @position
  end
  
  def property_name
    @property.name
  end
  
  def property_short_description
    @property.property_short_description  
  end

  def property_long_description
    @property.property_description  
  end

  def property_shortcut
    @property.shortcut
  end

  def property_google_map_code
    @property.google_map_code
  end

  def property_id
    @property.id
  end  
  
  def rate_search_id
    @rate_search_container.id
  end
  
  #deliver all available rates
  def rates
    return @rates if not @rates.nil?
    
    @rates = @db_rates.collect { |x| RateDrop.new(x, @rate_search_container) } 

    #drop uniq rates. could happen when there was a search for a rate code
    @rates = uniq_rates @rates

    return @rates
  end
  
  def empty    
    return true if @rates.empty?
    for rate in @rates
      return false if rate.is_available
    end
    return true
  end
  
  def settings
    @rate_search_container.settings
  end
  
  def pp_discount
    return false if @rate_search_container.settings.nil?
    @rate_search_container.settings.pp_discount
  end
  
  def has_rates
    debugger
    a = 1
    available = Property.has_rates[@property.id]
    return false if available.nil?
    return available
    return rates_available(rates)
  end
  
  def has_standard_rates
    return rates_available(standard_rates)
  end
  
  def has_package_rates
    return rates_available(package_rates)
  end
  
  #standard rates
  def standard_rates
    return @rates if not @rates.nil?    
    @rates = @rate_search_container.rates_for_period({:breakfast => false, :packages => false}).collect { |x| RateDrop.new(x, @rate_search_container, false) } rescue []
    return @rates.uniq
  end

  #packages
  def package_rates
    return @rates if not @rates.nil?    
    @rates = package_rates_without_breakfast.concat(package_rates_with_breakfast)
    return @rates.uniq
  end

  def package_rates_without_breakfast
    return @rate_search_container.rates_for_period({:breakfast => false, :packages => true}).collect { |x| RateDrop.new(x, @rate_search_container, false) } rescue []
  end  
  
  def package_rates_with_breakfast
    return @rate_search_container.rates_for_period({:breakfast => true, :packages => true}).collect { |x| RateDrop.new(x, @rate_search_container, true) } rescue []
  end
  
  #returns ticket_rates
  def ticket_rates
    r = self.rates
    r = r.collect{|x| x if x.is_ticket_rate}
    r = r.compact.uniq
    return r
  end
  
  #list of days for week starting arrival_date
  def week
    days 7
  end
  
  #list of days for month starting arrival_date
  def month
    days 31
  end
  
  #list of days of requested period
  def days
    list = []
    n = 0
    d = 7
    d = @rate_search_container.nights if @rate_search_container.nights > 7 
    
    while n < d
      list << @rate_search_container.arrival_date + n
      n += 1
    end
    list
  end
  
  #get week header
  def week_dates
    @week_list = []
    n = 0
    while n < (@rate_search_container.weeks * 7)
      @week_list << @rate_search_container.arrival_date + n
      n = n + 7
    end
    return @week_list    
  end
  
  def items
    @items = @rate_search_container.items.collect{|x| RateSearchItemDrop.new(x)}
  end
  
  def is_empty
    (@items.length == 0) rescue false
  end
  
  def total_price
    @rate_search_container.total_price
  end
  
  def valid
    return @rate_search_container.valid?
  end
  
  def arrival_date
    @rate_search_container.arrival_date.to_date
  end 
  
  def search_date
    @rate_search_container.arrival_date.strftime("%d.%m.%Y")
  end
  
  def leave_date
    @rate_search_container.arrival_date.to_date + @rate_search_container.nights
  end
  
  def nights
    @rate_search_container.nights
  end

  def weeks
    @rate_search_container.weeks
  end

  def months
    @rate_search_container.months rescue 0
  end
  
  def adults
    @rate_search_container.adults
  end
  
  #is this a weekly booking?
  def is_weeks
    @rate_search_container.weeks > 0
  end
  
  def rooms
    @rate_search_container.items.length
  end
  
  def charged_price
    @rate_search_container.charged_price
  end
  
  def deposit_charged
    @rate_search_container.charged_price != @rate_search_container.total_price 
  end
  
  def deposit
    @rate_search_container.charged_price
  end
  
  def booking_fee
    @rate_search_container.booking_fee
  end
  
  def has_booking_fee
    @rate_search_container.has_booking_fee?
  end
  
  def months_options
    text = ""
    for i in (1..12)
      selected = ''
      selected = 'selected="selected"' if months == i
      text << '<option value="' + i.to_s + '" ' + selected + '>' + i.to_s + '</option>'
    end
    text
  end

  def weeks_options
    text = ""
    for i in (1..12)
      selected = ''
      selected = 'selected="selected"' if weeks == i
      text << '<option value="' + i.to_s + '" ' + selected + '>' + i.to_s + '</option>'
    end
    text
  end  
  
  private
    #checks all rate drops for availability
    def rates_available rates
      for rate in rates
        return true if rate.is_available
      end
      return false
    end

    def uniq_rates rates
      uniqlist = []
      uniqrates = []
      
      n = 0
      
      while n < rates.length
        rate = rates[n]
        if not uniqlist.include?(rate.id)
          uniqlist << rate.id
          uniqrates << rate
        end
        n += 1
      end     
      
      return uniqrates
    end
end
