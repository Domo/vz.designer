class Voucher
  def initialize(record)
    @record = record
  end
  
  def method_missing(m, *args)
    puts "Methode entworfen: voucher.#{m}"
    eval("@record.#{m}")
  end
  
  def quantity
    return @quantity if @quantity
    @quantity = rand(20)+1
  end
  
  def id
    @record.id
  end
  
  def customer
    return @customer if @customer
    @customer = WSession.options.include?("vouchers_have_recipients") ? Database.find(:random, :customers) : nil
  end
  
  def recipient
    customer
  end
  
  def images
    if WSession.options.include? "voucher_images"
      return [RoomTypeImage.new("voucher")]
    end
    []
  end
  
  # Despite of its name, recipients_hash is an array of hashes.
  # This function will create single voucher objects with individual customers
  #----------------------------------------------------------------------------
  def create_single_vouchers_with_customers
    vouchers = []

    self.recipients_hash = [] if self.recipients_hash.nil?
    
    while self.recipients_hash.size < self.quantity
      self.recipients_hash << nil
    end
    
    #Create a new instance for every single recipient
    for r in self.recipients_hash
      if r.nil?
        vouchers << Voucher.find(self.id)
        next
      end
      
      v = Voucher.find(self.id)
      v.recipient = Customer.create_with_contact(r)
      vouchers << v
    end
    
    return vouchers
  end
    
end
