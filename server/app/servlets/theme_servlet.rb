require 'liquid_servlet'
require 'database'
require 'html_drop'
require 'flash_drop'
require 'property_drop'
require 'rate_search_drop'
require 'rate_search_item_drop'
require 'rate_drop'
require 'rate_room_type_drop'
require 'contact_drop'
require 'customer_drop'
require 'reservation_drop'
require 'reservation_room_type_drop'
require 'reservation_room_type'
require 'rate_search_container'
require 'creditcard_drop'
require 'booking_drop'
require 'booking_extra_drop'
require 'event_drop'
require 'event_availability_time'
require 'event_availability_time_drop'
require 'booking'
require 'money_filters'
require 'customer_setting'
require 'customer_setting_drop'
require 'customer_setting_events_drop'
require 'wsession'
require 'rate'

class ThemeServlet < LiquidServlet
	layout 'skin'
	
	def index
		@step = '1'
		if template_type == 'rooms'
    	render :type => :liquid
    else
    	render :type => :liquid, :action => 'tickets/search_tickets', :layout => 'tickets/skin'
    end
  end
  
  #Rooms actions
  
  def availability
  	@step = '2'
  	
  	@rate_search_drops = []
  	property = Database.find(:random, :properties)
  	property = Database.find(@params[:property], :properties) if @params[:properties]
		property.images = [RoomTypeImage.new("property")] if @options.include? "show_property_images"
  	rate_search_container = RateSearchContainer.new(property, @options)
  	drop = RateSearchDrop.new(property, rate_search_container)
  	
  	@rate_search_drops << drop

  	render :type => :liquid, :action => 'availability'
	end
	
	def occupancy
		@step = '3'
		event = Database.find(:random, :events)
		@event = event.name
		render :type => :liquid
	end
	
	def checkout
		@step = '4'
		@customer = CustomerDrop.new(Database.find(:random, :customers))
		@creditcard = CreditcardDrop.new
		render :type => :liquid
	end
	
	def process_reservation
		redirect_to '/confirmation'
	end
	
	def confirmation
		if template_type == 'rooms'
			@step = '5'
			@contact = ContactDrop.new(Database.find(:random, :contacts))
			@customer = CustomerDrop.new(Database.find(:random, :customers))
			@reservations = [ReservationDrop.new(Database.find(:random, :reservations))]
			render :type => :liquid
		else
			@step = '4'
			@contact = ContactDrop.new(Database.find(:random, :contacts))
			@customer = CustomerDrop.new(Database.find(:random, :customers))
			render :type => :liquid, :action => 'tickets/confirmation', :layout => 'tickets/skin'
		end
	end
	
	#Events actions
	
	def search_tickets
		@step = '2'
		if @params['act'] == 'didnt_find_tickets'
			@events = []
			(rand(3)+1).times do
				@events << EventDrop.new(Database.find(:random, :events))
			end
			render :type => :liquid, :action => 'tickets/didnt_find_tickets', :layout => 'tickets/skin'
		else
			@ats = []
			(rand(3)+1).times do
				@ats << EventAvailabilityTimeDrop.new(EventAvailabilityTime.new(@options), @booking.date)
			end
			render :type => :liquid, :action => 'tickets/found_tickets', :layout => 'tickets/skin'
		end
	end
	
	def terms_and_conditions
		@step = '2'
		render :type => :liquid, :action => 'tickets/terms_and_conditions', :layout => 'tickets/skin'
	end
	
	def payment_details
		@step = '3'
		@customer = CustomerDrop.new(Database.find(:random, :customers))
		@creditcard = CreditcardDrop.new
		render :type => :liquid, :action => 'tickets/payment_details', :layout => 'tickets/skin'
	end
	
	def do_payment
		redirect_to confirmation
	end
	
	#static page
	
	def static_page
		page = "static/" + @params["page"]
		layout = "skin" if template_type == 'rooms'
		layout = "tickets/skin" if template_type == 'events'
		# debugger
		if @params["no_layout"]
			render :type => :liquid, :action => page, :layout => 'none'
		else
			render :type => :liquid, :action => page, :layout => layout unless @params["no_layout"]
		end
	end
	
	#sonstige untermethoden, man weiß ja nie, worauf die Leute klicken...
	def add_room
		redirect_to '/occupancy'
	end
	
	def remove_room
		redirect_to '/occupancy'
	end
	
	def room_occupancy
		redirect_to '/occupancy'
	end
	
	def ajax_update_room
		#get params, prepare modules, set header
		@item_id = @params['id']
		@response['Content-Type'] = "text/javascript"
		money = MoneyFilter.new
		
		#update total price
		new_price = rand(100) + 10
		total_price = money.format_money(new_price, '&euro;')
		tag = "$('total_price').innerHTML = '" + total_price + "';"
		
		#Update price for the changed room
		room_price = money.format_money(rand(50) + 10, '&euro;')
		tag += "$('price_" + @item_id + "').innerHTML = '" + room_price + "';"
		
		#Get image lists
		images = build_images_for_occupancy_selects
		
		#Check if the skin contains space for the images, if yes, insert them.
		tag += "if (document.getElementById('img_adults_#{@item_id}')) {"
		tag += "$('img_adults_#{@item_id}').innerHTML = '" + images[:adults].join + "';"
		tag += "$('img_children_#{@item_id}').innerHTML = '" + images[:children].join + "';"
		tag += "}"
		
		render :text => tag
	end
	
	def template_type_cookie
  	@request.cookies.find { |c| c.name == 'template_type' }
	end
	
	def template_type
		if template_type_cookie.value
			if template_type_cookie.value != ''
				return template_type_cookie.value 
			end
		end
		return available_template_types.first
	end
	
	def available_template_types
		types = []
		types << "rooms" if File.exists? File.join(template_path, "skin.liquid")
		types << "events" if File.exists? File.join(template_path, "tickets")
		cookie = WEBrick::Cookie.new('template_type', types.first)
    cookie.path = '/'
    @response.cookies.push(cookie)
		return types
	end
  
  protected
  
  def before_filter
    cookie = @request.cookies.find { |c| c.name == 'theme' }
    
    if cookie.nil?
      redirect_to '/dashboard/'
    end

    # export drops
    @theme    = cookie.value      
		
    build_options_from_params
    build_global_assigns
    
    Rate.options = @options
    
    @nights = @params[:nights] || rand(5) + 1

    @template     = @action_name
    @handle       = @params['handle'] if @params['handle']
    @current_page = @params['handle'] == 'paginated-sale' ? 5 : 1 
    
    options_for_vision = @options.join("=1&") + "=1"
    
    @content_for_header = <<-HEADERS
    <!-- We inject some stuff here which you won't find on the live server. -->
    <!-- if you need prototype yourself you need to manually include it in your layout --> 
    <link rel="stylesheet" href="/stylesheets/vision/vision.css" type="text/css" media="screen" charset="utf-8" />
    <script type="text/javascript" src="/javascripts/vision/vision_html.js?action=#{@action_name}&#{options_for_vision}"></script>
    <script type="text/javascript" src="/javascripts/vision/vision.js?action=#{@action_name}"></script>
    <script type="text/javascript">
      window.onload = function() { initVisionPalette(); }
    </script>
    <script src="http://assets.visrez.com/roomsandevents/common/v_003/javascripts/fancyzoom.js" type="text/javascript"></script>
    <script type="text/javascript">
    	$(document).observe('dom:loaded', function() { 
    		$$('a.room_type_image_link').each(function(el) { new FancyZoom(el) }); } );
    		if (typeof Validation == 'undefined') {
					document.write('<script src=\"http://assets.visrez.com/roomsandevents/common/v_003/javascripts/validation.js\" type=\"text/javascript\"></scr' + 'ipt>');
				};
		</script>
		<script src="http://assets.visrez.com/roomsandevents/common/v_003/javascripts/date_validation_05.js" type="text/javascript"></script>
		<style media="screen,projection" type="text/css">
			#zoom table, #zoom table tr, #zoom table td {border: none;} 
			.room_type_image_link {cursor:url(http://assets.visrez.com/roomsandevents/common/v_003/images/fancyzoom/zoomin.cur), pointer;}
			.date_advice {
				z-index: 1000;
				width: 300px; 
				position: absolute; 
				top: 10px; 
				left: 10px; 
				padding:.5em;margin-bottom:1em;border:2px solid #ddd; 
				background:#FBE3E4;color:#8a1f11;border-color:#FBC2C4;
			}
		</style>
    <!-- end inject -->  
    HEADERS
  end
  
  #assigns, which are always needed 
  def build_global_assigns options = {}
    @selected_property = PropertyDrop.new(Database.find(:random, :properties))
    @property = PropertyDrop.new(Database.find(:random, :properties))
    @rate_search_container = RateSearchDrop.new(@property, RateSearchContainer.new)
    
    @booking = BookingDrop.new(Booking.new, Database.find(:random, :properties))
    event = Database.find(:random, :events)
    @event = EventDrop.new(event)
    
    if template_type == 'events'
    	@customer_settings = CustomerSettingEventsDrop.new(CustomerSetting.new, event)
    else
    	@customer_settings = CustomerSettingDrop.new(CustomerSetting.new)
    end
    
    #build options for HtmlDrop
    htmloptions = { :host => 'localhost', :local => true, :port => '3232', :controller => "" }  
    @html = HtmlDrop.new(htmloptions)
    
    @flash = FlashDrop.new(build_flash)
    @arrival_date = Time.new.strftime("%d.%m.%Y")
    
    @properties = Database.find(:all, :properties).collect {|p| PropertyDrop.new(p) }
    
    #  return {
    #   'html' => HtmlDrop.new(htmloptions),
    #   'config' => @config_drop,
    #   'property' => PropertyDrop.new(property),
    #   'selected_property' => PropertyDrop.new(selected_property),
    #   'third_party' => ThirdPartyDrop.new(session[:thirdparty]),
    #   'google_analytics_code' => @google_analytics_code,
    #   'properties' => Property.find(:all, :order => "name").collect{|x| PropertyDrop.new(x)},
    #   'customer_setting' => CustomerSettingDrop.new(csetting)
    # }
  end
  
  def build_options_from_params
  	@options = []
  	for param in @params.keys
  		next unless param.include? "options_"
  		@options << param.gsub("options_", "")
		end
	end
    
  def template_path
    "#{THEMES}/#{@theme}/templates"
  end
  
  def template_considering_cookies
    if cookie = @request.cookies.find { |c| c.name == "template_#{@action_name}" }
      cookie.value
    else
      @action_name
    end    
  end
  
  def build_flash
  	flash = {:error => '', :warning => '', :notice => ''}
  	if @options.include? "show_warning"
  		puts "found a warning"
  		flash[:warning] = 'This is a warning coming from the server, maybe a validation error.'
  	end
  	if @options.include? "show_notice"
  		puts "found a warning"
  		flash[:notice] = 'This is a notice, e.g. something like "Reservation successfully created"'
  	end
  	if @options.include? "show_error"
  		puts "found a warning"
  		flash[:error] = 'This is an error, e.g. something like a payment gateway error.'
  	end
  	return flash
	end
	  
  def path_scan
    
    matches = @request.path_info.gsub(/\+/,' ').scan(/\/([\w\s\-\.\+]+)/).flatten
    puts "matches: #{matches.inspect}"
    @action_name      = matches[0] if matches[0]
    @params['handle'] = matches[1] if matches[1]
    @params['tags']   = matches[2] if matches[2]
    
    #Sonderfälle
    if @action_name
	    if @action_name.include?('.html')
	    	@params['page'] = @action_name.gsub('.html', "")
	    	@action_name = 'static_page'
	    end
  	end
    
  end
  
  
  private
  
  def build_images_for_occupancy_selects
  	images = {:adults => [], :children => []}
		@params['adults'].to_i.times do
			images[:adults] << '<img src="http://assets.visrez.com/roomsandevents/common/v_001/images/adults.png" style="float:left;" class="adult-image" />'
		end
		@params['children'].to_i.times do
			images[:children] << '<img src="http://assets.visrez.com/roomsandevents/common/v_001/images/child.png" style="float:left;" class="child-image" />'
		end
		return images
	end

  
end

