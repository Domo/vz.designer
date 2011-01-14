class VoucherDrop < Liquid::Drop
  require "customer_drop"
  require "contact_drop"
  
  def my_name
    "RateDrop"
  end
  
  def self.clear_cart_onclick
    "window.location.href = '/'; return false"
  end
  
  def initialize(voucher, recipient = nil)
    @voucher = voucher
    @recipient = recipient
  end
  
  def code
    @voucher.code.nil? ? "" : @voucher.code
  end
  
  def id
    @voucher.id
  end
  
  def name
    @voucher.name
  end
  
  def price
    @voucher.price
  end
  
  def price_for_quantity
    price * quantity
  end
  
  def quantity
    @voucher.quantity
  end
  
  def description
    @voucher.description
  end
  
  def image_tag
    return "" if @voucher.images.length == 0
    '<img src="' + @voucher.images.first.public_filename('normal') + '" alt="' + @voucher.name + '"/>'
  end      

  def thumb_tag
    return "" if @voucher.images.length == 0
    '<img src="' + @voucher.images.first.public_filename('geomety') + '" alt="' + @voucher.name + '"/>'
  end    
  
  def custom_tag
    return "" if @voucher.images.length == 0
    '<img src="' + @voucher.images.first.public_filename('custom') + '" alt="' + @voucher.name + '"/>' rescue "no custom image."
  end  
  
  def custom_image
    return "" if @voucher.images.length == 0
    @voucher.images.first.public_filename('custom') rescue "" 
  end
  
  def original_image_tag
    return "" if @voucher.images.length == 0
    '<img src="' + @voucher.images.first.public_filename + '" alt="' + @voucher.name + '"/>'
  end  
  
  def has_image
    !@voucher.voucher_image.nil?
  end
  
  def public_image
    image_tag
  end
  
  # Generates an amount select for web_vouchers/list.
  # select-id: voucher_id + "amount"
  #----------------------------------------------------------------------------
  def amount_select
    tag = "<select id=\"voucher_#{@voucher.id}_amount\">"
    for i in (1..20)
      tag += "<option value=\"#{i}\">#{i}</option>"
    end
    tag += "</select>"
  end
  
  # Generates the onclick javascript for the "Add Voucher" Buttons with amount select
  #----------------------------------------------------------------------------
  def add_voucher_amount_onclick
    return <<-eos
        new Ajax.Updater('shopping-cart', 
                      '/web_vouchers/ajax_add_voucher/#{@voucher.id}', {
                        asynchronous:true, 
                        evalScripts:true, 
                        parameters: {
                          amount: $F('voucher_#{@voucher.id}_amount')
                        }, 
                        onComplete: function(request) {
                          $('shopping-cart').scrollTo()
                        }
                       }); 
      return false;
    eos
  end
  
  # Generates the onclick javascript for "Add Voucher" links without amount select
  #----------------------------------------------------------------------------
  def add_voucher_onclick
    return <<-eos
      new Ajax.Updater('shopping-cart', 
                      '/web_vouchers/ajax_add_voucher/#{@voucher.id}', {
                        asynchronous:true, 
                        evalScripts:true, 
                        onComplete: function(request) {
                          $('shopping-cart').scrollTo()
                        }
                       }); 
      return false;
    eos
  end

  # Generates the onclick javascript for the "Remove 1 Voucher" links in the cart
  #----------------------------------------------------------------------------
  def decrease_voucher_onclick(amount = 1)
    "new Ajax.Updater('shopping-cart', '/web_vouchers/ajax_remove_voucher/#{@voucher.id}?amount=#{amount}', {asynchronous:true, evalScripts:true}); return false;"
  end
  
  # Generates the onlick javascript for the "Remove All" links in the cart.
  #----------------------------------------------------------------------------
  def remove_voucher_onclick
    decrease_voucher_onclick(quantity)
  end
  
  # The Customer for the recipient
  #----------------------------------------------------------------------------
  def customer
    CustomerDrop.new(@voucher.customer)
  end
  
  # The contact for the recipient
  #----------------------------------------------------------------------------
  def contact
    @voucher.customer.nil? ? nil : ContactDrop.new(@voucher.customer.main_contact)
  end
  
  # Returns true if there is a contact set for the recipient (which means, there is a recipient set)
  #----------------------------------------------------------------------------
  def has_recipient
    return false if @voucher.recipient.nil?
    return true
  end
  
  # The onsubmit-action which updates a recipient via ajax
  #----------------------------------------------------------------------------
  def update_recipient_onsubmit
    tag = <<-eos
           new Ajax.Updater('vouchers_recipients', '/web_vouchers/ajax_update_recipient', {
              parameters: this.serialize(),
              evalscripts: true
            }); return false
        eos
    return tag
  end
end
