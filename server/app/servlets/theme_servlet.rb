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
require 'wsession'

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
  	
  	prop = Database.find(@selected_property.id, :properties)
  	drop = RateSearchDrop.new(prop)
  	
  	@rate_search_drops << drop

  	render :type => :liquid, :action => 'availability'
	end
	
	def occupancy
		@step = '3'
		render :type => :liquid
	end
	
	def checkout
		@step = '4'
		@rate_search_container = ReservationDrop.new(Database.find(:random, :reservations))
		render :type => :liquid
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
			render :type => :liquid, :action => 'tickets/confirmation', :layout => 'tickets/skin'
		end
	end
	
	#Events actions
	
	def search_tickets
		@step = '2'
		if @params[:act] == 'didnt_find_tickets'
			render :type => :liquid, :action => 'tickets/didnt_find_tickets', :layout => 'tickets/skin'
		else
			render :type => :liquid, :action => 'tickets/found_tickets', :layout => 'tickets/skin'
		end
	end
	
	def terms_and_conditions
		@step = '2'
		render :type => :liquid, :action => 'tickets/terms_and_conditions', :layout => 'tickets/skin'
	end
	
	def payment_details
		@step = '3'
		render :type => :liquid, :action => 'tickets/payment_details', :layout => 'tickets/skin'
	end
	
	def do_payment
		redirect_to confirmation
	end
	
	def template_type_cookie
  	@request.cookies.find { |c| c.name == 'template_type' }
	end
	
	def template_type
		template_type_cookie.value || "rooms" rescue "rooms"
	end
  
  protected
  
  def before_filter
    cookie = @request.cookies.find { |c| c.name == 'theme' }
    
    if cookie.nil?
      redirect_to '/dashboard/'
    end

    # export drops
    @theme    = cookie.value        
		
    build_global_assigns

    @template     = @action_name
    @handle       = @params['handle'] if @params['handle']
    @current_page = @params['handle'] == 'paginated-sale' ? 5 : 1 
    
    @content_for_header = <<-HEADERS
    <!-- We inject some stuff here which you won't find on the live server. -->
    <!-- if you need prototype yourself you need to manually include it in your layout --> 
    <link rel="stylesheet" href="/stylesheets/vision/vision.css" type="text/css" media="screen" charset="utf-8" />
    <script type="text/javascript" src="/javascripts/vision/vision_html.js?action=#{@action_name}"></script>
    <script type="text/javascript" src="/javascripts/vision/vision.js?action=#{@action_name}"></script>
    <script type="text/javascript">
      window.onload = function() { initVisionPalette(); }
    </script>
    <!-- end inject -->  
    HEADERS
#    @content_for_header = ""    
  end
  
  #assigns, which are always needed 
  def build_global_assigns options = {}
    @selected_property = Database.find(:first, :properties)
    @property = Database.find(:random, :properties)
    # csetting = CustomerSetting.find(:first) 
    # csetting = CustomerSetting.new if csetting.nil?    
    
    #build options for HtmlDrop
    htmloptions = { :host => 'localhost', :local => true, :port => '3232', :controller => "" }  
    @html = HtmlDrop.new(htmloptions)
    
    @flash = FlashDrop.new({})
    @arrival_date = Time.new.strftime("%d.%m.%Y")
    @nights = @params[:nights] || '1'
    
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
  
  def path_scan
    
    matches = @request.path_info.gsub(/\+/,' ').scan(/\/([\w\s\-\.\+]+)/).flatten
    puts "matches: #{matches.inspect}"
    @action_name      = matches[0] if matches[0]
    @params['handle'] = matches[1] if matches[1]
    @params['tags']   = matches[2] if matches[2]
    
    if @action_name == "skin"
    	@req_file = []
    	for match in matches
    		next if match == matches[0]
    		@req_file << match
  		end
  		@req_file = @req_file.join("/")
    end
  end
  
end

