class ReservationRoomTypeDrop < Liquid::Drop
  
  def initialize(_reservation_room_type)
    @reservation_room_type = _reservation_room_type
  end
  
  def property_room_type_room_type_name
    @reservation_room_type.property_room_type.room_type.name
  end
  
  def rooms
    @reservation_room_type.reservation_rooms.collect { |room| ReservationRoomDrop.new(room) }
  end
  
  def package_min_people
    @reservation_room_type.package_room_type_rate.min_people
  end
  
  def room_type_id
    @reservation_room_type.room_type.id
  end
  
  def nights
    @reservation_room_type.nights
  end
  
  def property_room_type_id
    @reservation_room_type.property_room_type.id
  end
  
  def room_type_name
    @reservation_room_type.room_type.name
  end
  
  def its_package
    @reservation_room_type.package_room_type_rate.nil? ? false : true
  end
  
  def package_name
    @reservation_room_type.package_room_type_rate.package_property_rate.name
  end
  
  def adults
    @reservation_room_type.adults
  end
  
  def children
    @reservation_room_type.children
  end
  
  def people
    @reservation_room_type.adults + @reservation_room_type.children
  end
  
  def price
    @reservation_room_type.sell_price
  end
  
  def has_room_type_image
    (@reservation_room_type.room_type.images.length == 0 ? false : true)
  end
  
  def room_type_image_src
    @reservation_room_type.room_type.images.first.public_filename('geomety')
  end
  
  def custom_tag
    return "" if @reservation_room_type.images.length == 0
    '<img src="' + @reservation_room_type.images.first.public_filename('custom') + '" alt="' + @reservation_room_type.name + '"/>' rescue "no custom image."
  end  
  
  def custom_image
    return "" if @reservation_room_type.images.length == 0
    @reservation_room_type.images.first.public_filename('custom') rescue "" 
  end  
  
  def room_type_description
    @reservation_room_type.room_type.description
  end
  
  #event stuff
  def is_ticket_rate
    return @reservation_room_type.rate.is_ticket_rate
  end
  
  def rate
    return RateDrop.new(@reservation_room_type.rate, nil)
  end
  
  def event_names
    return "" if not is_ticket_rate
    return @reservation_room_type.rate.assigned_events_names
  end  
end
