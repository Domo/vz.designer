# actions for all booking steps in rooms, voucher, golf and event booking process
class HtmlDrop < Liquid::Drop

  def initialize(values)
    @local = values[:local]
    @port = values[:port]
    @host = values[:host] + port_formatted
    @controller = values[:controller]
  end

  #room reservation actions
  def availability_action
    no_ssl_link + "/availability"
  end
  
  def occupancy_action
    no_ssl_link + "/room_occupancy"  
  end
  
  def checkout_action
    ssl_link + "/checkout"
  end
  
  def process_reservation_action
     ssl_link + "/process_reservation"
  end
  
  #golf actions
  def select_tee_time_action
    no_ssl_link + "/select_tee_times"  
  end
  
  def terms_and_conditions_action
    no_ssl_link + "/terms_and_conditions"  
  end
  
  def payment_details_action
    ssl_link + "/payment_details"  
  end
  
  def do_payment_action
    ssl_link + "/do_payment"  
  end
  
  #event actions
  def search_tickets_action
    no_ssl_link + "/search_tickets"  
  end  

  #def terms_and_conditions_action <- like in golf
  #def payment_details_action <- like in golf
  #def do_payment_action <- like in golf
  
  #voucher actions
  #def checkout_action <- like in rooms 
  def process_payment_action
    ssl_link + "/process_payment"  
  end
    
  #helper methods
  private
  def ssl_link
    protocol(true) + @host + controller_formatted
  end
  
  def no_ssl_link
    protocol(false) + @host + controller_formatted
  end
  
  def protocol(ssl)
   return "http://" if @local or not ssl
   return "https://"
  end
  
  def port_formatted
    return ":" + @port.to_s if @port != 80 and @port != 443
    return ""
  end
  
  def controller_formatted
    return "/" + @controller unless @controller == ""
		return @controller    
  end
end
