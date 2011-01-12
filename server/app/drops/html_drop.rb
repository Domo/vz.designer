# actions for all booking steps in rooms, voucher, golf and event booking process

class HtmlDrop < Liquid::Drop
  include VisrezFilter
  
  def initialize(values)
    @local = values[:local]
    @port = values[:port]
    @host = values[:host] + port_formatted
    @controller = values[:controller]
    @customer_settings = values[:customer_settings]
    @web_settings = values[:web_settings]
    @properties = values[:properties]
    @selected_property = values[:selected_property]
    @date = values[:date]
    @nights = values[:nights]
    @promotion = values[:promotion]
  end

  #search form
  def search_form
    form = '
      <form action="' + self.availability_action + '" method="post" id="availability_search_form">
          <p id ="searcharrivaldate">
            <label for="arrival_date">Arrival</label>
            <input type="text" id="arrival_date" name="rate_search_container[arrival_date]" value="' + @date.to_s(:eu) + '" />
            <a href="#"><img alt="Calendar" id="day_calendar" src="' + common_asset('images/calendar.gif')+ '" /></a>
            <script type="text/javascript">Calendar.setup({inputField: "arrival_date", ifFormat: "%d.%m.%Y", button: "day_calendar"});</script>
          </p>
         
          <p id="searchnights"><label for="reservation_search_nights">Nights</label>
          <select name="nights" id="reservation_search_nights">'
          
          for i in (1..7)
            selected = ""
            selected = 'selected="selected"' if i == @nights.to_i
            form << "<option value=\"#{i}\" #{selected}>#{i}</option>"          
          end
          
          form << '
          {% for i in (1..7) -%}
              
          {% endfor -%}
          </select>
        </p>
    '
    
    if @customer_settings.promo_show_box
      v = ""
      v = @promotion.promo_code if not @promotion.nil?
      form << '<p id="searchpromocode">
        <label for="promocode">Promotion Code</label>
        <input type="text" name="promocode" id="promocode" value="' + v + '"/>
      </p>'
    end
    
    #show property selector
    if @web_settings.show_property_selector
      form << '
      <p id="searchproperty">
      <label for="property">Hotel</label>
      <select name="property" id="property">'
      #build properties
      for p in @properties
        selected = ""
        selected = 'selected="selected"' if p.id == @selected_property
        form << "<option value=\"#{p.id}\" #{selected}>#{p.name}</option>"
      end
      form << '</select></p>'
    end
    
    #submit button
    form << '     
      <p id="searchsubmit">
      <button type="submit" value="Check Availability" id="searchbutton"><span class="alt">Check Availability</span></button>
      </p>          
      </form>'
  end
  
  def selected_property
    @selected_property
  end

  #room reservation actions
  def availability_action
  	unless @promotion.nil?
    	no_ssl_link + "promo/" + @promotion.promo_code
  	else
  		no_ssl_link + "/availability"
  	end
 end
 
  def calendar_action
    no_ssl_link + "/calendar"
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
  
  # Action used to validate creditcard and entered recipients,
  # will also display a summary before the final checkout.
  #----------------------------------------------------------------------------
  def process_validation_action
    ssl_link + "/process_validation"  
  end
  
  #Refreshing the shopping cart
  def shopping_cart_action
    ssl_link + "/shopping_cart"
  end
  
  def shopping_cart_refresh
    element = "booking_cart"
    form = "booking_form"
    "new Ajax.Updater('#{element}', '#{shopping_cart_action}', {asynchronous:true,parameters:$('#{form}').serialize()});"  
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
    if @promotion.nil?
      "" + @controller
    else
      ""
    end
  end
end
