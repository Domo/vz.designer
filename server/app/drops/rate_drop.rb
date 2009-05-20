class RateDrop < Liquid::Drop
  def initialize(_rate)
    @rate = _rate 
    rate_room_types = Database.find(:condition, :rate_room_types, "rate_id=" + @rate.id.to_s)
    @room_types ||= rate_room_types.collect { |x| RateRoomTypeDrop.new(x, @rate) }
  end
  
  def id
    @rate.id
  end
  
  def code
    @rate.code
  end
  
  def is_per_person_sharing
    is_per_room_sharing
  end
  
  def is_per_room_sharing
    return true if @rate.sharing_options == 2
    return false    
  end
  
  def tickets
    @ticket_bundles
  end
  
  #is this a package?
  def is_package
    @rate.restrictions_active  
  end  
  
  #Getters for Rate Attributes
  def name
    @rate.name
  end

  def description
    @rate.description
  end
  
  #Ticketbundle data
  def tickets
    return [] if not @rate.is_ticket_rate?
    
    list = []
    
    for bundle in @rate.ticketbundles
      list << bundle if bundle.applies_for_day? @rate_search_container.arrival_date
    end
    
    @tickets = list.collect{ |x| TicketBundleDrop.new(x)  }
  end
  
  #Wrap RateRoomTypes in Drops and return list
  def room_types
    @room_types
  end
 
  #rate available at all?
  def is_available
    return @is_available if not @is_available.nil?
    @is_available = false
    return false if @room_types.nil? or @room_types.length == 0
    not_available = 0
    for room_type in @room_types
      not_available += 1 if (not room_type.is_bookable or not room_type.is_available_for_period)
    end
    return false if not_available == @room_types.length
    @rate.property.has_rates = {} if @rate.property.has_rates.nil?
    Property.has_rates[@rate.property.id] = true
    @is_available = true
    return @is_available
  end
  
  #true if there are ticketbundles
  def is_ticket_rate
    return @rate.is_ticket_rate?
  end  
  
  def image_tag
    return "" if @rate.images.length == 0
    '<img src="' + @rate.images.first.public_filename('geomety') + '" alt="' + @rate.name + '"/>'
  end

  def image_tags
    return "" if @rate.images.length == 0
    text = ""
    for image in @rate.images
      text << '<img src="' + @rate.images.first.public_filename('geomety') + '" alt="' + @rate.name + '"/>'  
    end
  end  
  
  def custom_tag
    return "" if @rate.images.length == 0
    '<img src="' + @rate.images.first.public_filename('custom') + '" alt="' + @rate.name + '"/>' rescue "no custom image."
  end  
  
  def custom_image
    return "" if @rate.images.length == 0
    @rate.images.first.public_filename('custom') rescue "" 
  end  
  
  #daily booking possible
  def daily
    return @rate.daily
  end

  #monthly booking possible
  def monthly
    return @rate.monthly
  end
  
  #weekly booking possible
  def weekly
    return @rate.weekly
  end
  
  #is there only a deposit charged?
  def deposit_charged
    return @rate.deposit > 0
  end
  
  def to_xml
    xml = "<rate name=\"#{encode_entities(name)}\">"
    for room_type in room_types
      xml << room_type.to_xml
    end
    xml << "</rate>"   
  end
end
