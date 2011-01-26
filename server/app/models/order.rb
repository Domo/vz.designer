#------------------------------------------------------------
#              This is a model for Voucher Sales
#------------------------------------------------------------

class Order
  
  def initialize
    
  end 
  
  def id
    rand(100000)+1
  end
  
  def total_price
    return @total if @total
    @total = rand(10000)+1.05
  end
  
  def booking_fee
    return rand(5)
  end
  
  def booking_fee?
    return WSession.options.include? "booking_fee"
  end
  
  def deposit
    total_price * 0.3
  end
  
  def deposit?
    return WSession.options.include? "deposit_charged"
  end
  
  # Returns the currently set voucher prefix and self.id (like Booking references)
  #----------------------------------------------------------------------------
  def full_reference
    "VOUCHERPREFIX" + self.id.to_s
  end
  
end
