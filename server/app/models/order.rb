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
    rand(10000)+1.05
  end
  
  def booking_fee
    return rand(5)
  end
  
  # Returns the currently set voucher prefix and self.id (like Booking references)
  #----------------------------------------------------------------------------
  def full_reference
    "VOUCHERPREFIX" + self.id.to_s
  end
  
end
