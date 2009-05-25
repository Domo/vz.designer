class ReservationDrop < Liquid::Drop
  def initialize(_reservation)
    @reservation = _reservation
  end
  
  def id
    @reservation.id
  end
  
  def reservation_room_types
    @reservation.reservation_room_types.collect { |room_type| ReservationRoomTypeDrop.new(room_type) }
  end
  
  def customer_name
    @reservation.customer.name
  end
  
  def sell_price
    @reservation.sell_price
  end
  
  def arrival_date
    @reservation.arrival_date.to_date
  end
  
  def departure_date
    @reservation.departure_date.to_date
  end
  
  def is_package_reservation
    for r in @reservation.reservation_room_types
      if not r.package_room_type_rate_id.nil?
        return true
      end
    end
    return false
  end
  
  def deposit_charged
    @reservation.paid < @reservation.sell_price
  end  
  
  def deposit
    @reservation.paid
  end
  
  def outstanding
    @reservation.sell_price - @reservation.paid
  end
  
  def has_tickets
    if @reservation.bookings.empty?
      return false
    end
    return true
  end
  
  def ticket_bookings
    @reservation.bookings.collect{|x| BookingDrop.new(x, @reservation.reservation_room_types.first.property_room_type.property)}
  end
  
  def special_request
    return @reservation.special_request if not @reservation.special_request.nil?
    return ""
  end
  
end
