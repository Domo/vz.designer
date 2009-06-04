class RateDayDrop < Liquid::Drop
  def initialize(source)
    @source = source
  end  
  
  def date
    @source.date
  end
  
  #XML export
  def to_xml
    xml = ""
    xml << "<rate-day>"
    xml << "<date>" + date.to_s + "</date>"
    xml << "<price>" + price_for_day.to_s + "</price>"
    xml << "<free-night>" + free.to_s + "</free-night>"
    xml << "</rate-day>"
    xml
  end  
  
  def formatted_date
    @source.date.to_s(:eu)  
  end
  
  def rate_room_type_id
    @source.rate_room_type.id
  end
  
  def part_of_request
    @source.part_of_request
  end
  
  def weekday_short
    @source.weekday_short
  end
  
  def weekday_long
    @source.weekday_long
  end
  
  def day_of_month
    @source.date.mday
  end
  
  def previous_month
    @source.previous_month
  end
  
  def next_month
    @source.next_month
  end

  def actual_month
    @source.actual_month
  end
  
  def month
    @source.date.month
  end
  
  #return true if this is a free night
  def free
    @source.free
  end
  
  #price for rate_room_type on that day
  def price_for_day
    @source.price_for_day
  end

  def is_available
    @source.is_available
  end

  def available_rooms
    @source.available_rooms
  end

  def available_class
    return "day-available" if (@source.part_of_request and not @source.price_for_day.nil?)
  end

  def has_price
    @source.has_price
  end  
end
