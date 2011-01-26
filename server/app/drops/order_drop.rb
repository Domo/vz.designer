class OrderDrop < Liquid::Drop
  
  def initialize(order)
    @order = order
  end
  
  def errors
    @order.errors
  end
  
  def id
    @order.id
  end
  
  def total_price
    @order.total_price
  end
  
  def booking_fee
    @order.booking_fee
  end
  
  def booking_fee_included
    @order.booking_fee?
  end
  
  def deposit
    @order.deposit
  end
  
  def deposit_taken
    @order.deposit?
  end
  
  # Returns the currently set voucher prefix and self.id (like Booking references)
  #----------------------------------------------------------------------------
  def full_reference
    @order.full_reference
  end
  
end
