class RateRoomTypeDrop < Liquid::Drop
  def initialize(_rate_room_type, _rate)
    @rate_room_type = _rate_room_type
    @rate = _rate
  end  
  
  #list of days for week starting arrival_date
  def week
    days 7
  end
  
  #list of days for month starting arrival_date
  def month
    days 31
  end
  
  def long_description
    @rate_room_type.room_type.description
  end
  
  def short_description
    @rate_room_type.room_type.short_description
  end
  
  def image_link_geometry
	  image_link('geomety')
  end
  
  def image_link_normal
	  image_link('normal')
  end
  
  def image_link_thumb
	  image_link('thumb')
  end
  
  
  def image_link(version = 'geomety')
    if has_image?
			if version == 'geomety'
				element_id = "image_" + @rate_room_type.room_type.images.first.id.to_s rescue "0"
				javascript = "new FancyZoom($('" + element_id + "'));"
				big_image = custom_tag
				big_image = image_link("normal") unless @rate_room_type.room_type.images.first.has_child?("custom")
				link =  '<a href="#' + element_id + '_big" id="' + element_id + '" class="room_type_image_link"><img src="' + image_path(version) + '" alt="Room Image" /></a>'
				link << '<div id="' + element_id + '_big" style="display:none;">' + big_image + '</div>'
			else
				link = '<img src="' + image_path(version) + '" alt="Room Image" />'
			end
			return link
    else
      return ""
    end
  end
    
  def has_image?
    (@rate_room_type.room_type.images.length>0) ? true : false
  end
  
  def image_path(version = 'geomety')
    @rate_room_type.room_type.images.first.public_filename(version) rescue ""
  end
  
  def custom_tag
    return "" if @rate_room_type.room_type.images.length == 0
    '<img src="' + @rate_room_type.room_type.images.first.public_filename('custom') + '" alt="' + @rate_room_type.room_type.name + '"/>' rescue "no custom image."
  end  
  
  def custom_image
    return "" if @rate_room_type.room_type.images.length == 0
    @rate_room_type.room_type.images.first.public_filename('custom') rescue "" 
  end  
  
  #list of days with pricing
  #default is 7 for week
  def days
    @rate_room_type.days(@rate_search_container).collect{|x| RateDayDrop.new(x)}
  end
  
  #is this room available in requested period?
  def is_available_for_period
    return @available if not @available.nil?
    @available = @rate_room_type.has_prices_for_period(@rate_search_container)
    return @available
  end
  
  #calculate price for that room type
  def room_price_for_period
    @rate_room_type.sum_days_for_period(@rate_search_container)
  end

  #bookable validation
  def is_bookable
    return @rate_room_type.is_bookable(@rate_search_container.arrival_date, @rate_search_container.nights, @rate_search_container.adults)
  end

  def name
    @rate_room_type.room_type.name
  end

  def id
    @rate_room_type.id
  end  
  
  #xml export
  def to_xml
    xml = "<rate_room_type id=\"#{id.to_s}\">"
    xml << "<name>#{encode_entities(name)}</name>"
    xml << "<short-description>#{encode_entities(short_description)}</short-description>"
    xml << "<long-description>#{encode_entities(long_description)}</long-description>"
    for day in days
      xml << day.to_xml
    end
    xml << "</rate_room_type>"
  end
  
  #gets hash with parameters for "Book" link
  def book_link_params
    {:action => "reservation_step_3", :rate_room_type => @rate_room_type.id, :date => @rate_search_container.arrival_date, :nights => @rate_search_container.nights}
  end   
  
  #gets url for "Book" link (liquid templates cannot understand rails' links)
  def liquid_book_link_params
    "/web_reservations/room_occupancy?rate_room_type=#{@rate_room_type.id}&amp;date=#{@rate_search_container.arrival_date}&amp;nights=#{@rate_search_container.nights}&amp;property_id=#{@rate_search_container.property.id}"
  end 
  
  #not escaped
  def liquid_book_link_params_no_escape
    liquid_book_link_params.gsub(/\&amp;/, "&")
  end 
  
  #show calendar
  def month_calendar
    if is_available_for_period
      #show_navi: always false, because it uses "link_to_remote", which is
      #not usable here (is not included)
      list = []      
      for d in (0..@rate_search_container.nights-1)
        list << @rate_search_container.arrival_date + d
      end
      show_calendar_widget({:show_navi => false, :exclude_months =>true, :days => list})
    end
  end
  
  #list of monthdrops for request
  def months
    return @month_list if not @month_list.nil?
    @month_list = []

    month_collection = {}

    #group days by month
    for d in days(@rate_search_container.nights)
      month_collection[Date.new(d.date.year,d.date.month,1)] = [] if month_collection[Date.new(d.date.year,d.date.month,1)].nil?
      month_collection[Date.new(d.date.year,d.date.month,1)] << d
    end

    month_collection = month_collection.sort
    # now, month_collection is an array!! http://www.ruby-doc.org/core/classes/Hash.html#M000176

    for m in month_collection
      @month_list << RateMonthDrop.new(m[1])
    end
    
    return @month_list

  end
  
  #average price per month
  def average_price_per_month
    return @average_price_per_month if not @average_price_per_month.nil?
    counter = 0
    price = 0.0
    for m in @month_list
      price += m.price_for_month
      counter += 1
    end
    @average_price_per_month = price / counter
    return @average_price_per_month
  end
  
  def number_of_months
    months.length + 2
  end
  
  def weeks
    return @week_list if not @week_list.nil?
    @week_list = []
    
    week_collection = []

    counter = 0
    week_number = 0

    #group days by week
    day_list = days
    day_list = day_list.sort{|y,x| y.date <=> x.date}
    
    for d in day_list 
      week_collection[week_number] = [] if week_collection[week_number].nil?
      week_collection[week_number] << d
      counter += 1
      if counter == 7
        counter = 0 
        week_number += 1
      end
    end

    for w in week_collection
      @week_list << RateWeekDrop.new(w)
    end
    
    return @week_list    
  end
  
  def average_price_per_week
    return @average_price_per_week if not @average_price_per_week.nil?
    counter = 0
    price = 0.0
    for m in @week_list
      price += m.price_for_week
      counter += 1
    end
    @average_price_per_week = price / counter
    return @average_price_per_week
  end
  
  def number_of_weeks
    weeks if @week_list.nil?
    @week_list.length + 2    
  end
end
