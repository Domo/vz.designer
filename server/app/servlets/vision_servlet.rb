require 'servlet'
require 'wsession'

class VisionServlet < Servlet      
	
	def my_name
		"vision"
	end
  
  def vision_js
    @response["Content-Type"] = 'text/javascript'    
    
    render :action => 'vision', :type => 'js'
  end
  
  def vision_css
    @response["Content-Type"] = 'text/css'    
    
    render :action => 'vision', :type => 'css'
  end
  
  def vision_html_js
    @current_theme = theme_cookie.value || 'None selected'
    @current_template = WSession.current_template
    @current_template_type = template_type
    
    @themes = themes_for_view
    @templates = templates_for_view   
    @template_types = template_types_for_view
    @params = @params
    
    @options = [{ :name => 'show_error', :caption => 'Show an error notification' },
								 { :name => 'show_notice', :caption => 'Show a notification' },
								 { :name => 'show_warning', :caption => 'Show a warning notification' }]
								 
		@template_options = options_for_template
								 
    rhtml = render(:action => 'vision', :type => 'rhtml')
    "var vision_html = '#{escape_javascript(rhtml)}';"
  end
  

  # The values for the Template pack select
  #----------------------------------------------------------------------------
	def template_types_for_view
		tt = {}
		if File.exists?(theme_template_path + '/skin.liquid')
			tt[:rooms] = 'Rooms-Templates'
		end
		if File.exists?(theme_template_path + '/tickets')
			tt[:events] = 'Events-Templates'
		end
		if File.exists?(theme_template_path + '/vouchers')
      tt[:vouchers] = 'Voucher-Templates'
    end
		return tt
	end
	
	def options_for_action
		return [{ :name => 'show_error', :caption => 'Show an error notification' },
								 { :name => 'show_notice', :caption => 'Show a notification' },
								 { :name => 'show_warning', :caption => 'Show a warning notification' },
								 { :name => 'records_have_errors', :caption => "Server validation failed for input" }]
	end
	
	def options_for_template
		options =  [{ :name => 'show_rate_images', :caption => 'Rates have images', :for => 'availability' },
									{ :name => 'show_property_images', :system_types => "rooms, events, vouchers", :caption => 'Properties have images (used nowhere atm)', :for => 'availability' },
									{ :name => 'dont_show_room_images', :system_types => "rooms", :caption => 'Rooms have <b>no</b> images', :for => 'availability' },
									{ :name => 'show_website_discount', :system_types => "events", :caption => 'Show Website Discount', :for => 'search_tickets'},
									{ :name => 'rates_are_ticket_rates', :system_types => "rooms", :caption => 'Rates are Ticket Rates (for Rooms&Events)', :for => 'availability, occupancy, checkout, confirmation'},
									{ :name => 'deposit_charged', :system_types => "events, vouchers", :caption => 'Booking has Deposit', :for => 'terms_and_conditions, payment_details, confirmation, checkout, list'},
									{ :name => "booking_has_questions", :system_types => "events", :caption => "Booking has questions", :for => "confirmation, payment_details, checkout"},
									{ :name => "voucher_images", :system_types => "vouchers", :caption => "Vouchers have images", :for => "list, checkout"},
									{ :name => "cart_contains_vouchers", :system_types => "vouchers", :caption => "Shopping Cart contains vouchers", :for => "list, checkout"},
									{ :name => "vouchers_have_recipients", :system_types => "vouchers", :caption => "Cart Vouchers have recipients", :for => "checkout"},
									{ :name => 'records_have_errors', :system_types => "vouchers", :caption => 'Vouchers have usage codes', :for => 'confirmation' },
									{ :name => 'booking_fee', :system_types => "events, vouchers", :caption => 'Booking fee included', :for => 'terms_and_conditions, payment_details, confirmation, checkout, list'},
		]
		
		return options.map {|o| o if o[:for].include?(@current_template)}.compact
	end

  def templates_for_view
		#current template
		available_templates = [["Cookie.destroy('#{@params['action']}'); window.location.reload();", "#{WSession.current_template}.liquid"]]
    
		#static templates
		if File.exists?("#{theme_template_path}/static")
  		available_templates << ['', '---- Static Templates ----'] 
      Dir["#{theme_template_path}/static/*.liquid"].each do |f|
        variant = File.basename(f, File.extname(f))
        available_templates << ["window.location='#{variant}.html';", "#{variant}.liquid"]
      end
    end
    
    available_templates << ['', '-------------']      
    available_templates += standard_templates.collect do |loc, name|
      ["window.location='#{loc}';", name]
    end
    available_templates
  end
  
  def themes_for_view
    Dir[THEMES + '/*'].collect do |theme|
      next unless File.directory?(theme)
      File.basename(theme)
    end.compact
  end
  
  def standard_templates
  	st = {:rooms => [  ['/', 'Frontpage (Index)'], 
       ['/availability', 'Room Availability Page'], 
       ['/occupancy', 'Room Occupancy Page'], 
       ['/checkout', 'Checkout Page (Customer Details)'], 
       ['/confirmation', 'Confirmation Page']
       ],
      :events => [  ['/', 'Frontpage (Search Tickets)'], 
       ['/search_tickets', 'Found Tickets Page'], 
       ['/terms_and_conditions', 'Terms & Conditions Page'], 
       ['/payment_details', 'Payment Details Page'], 
       ['/confirmation', 'Confirmation Page'], 
       ['/search_tickets?act=didnt_find_tickets', 'Did not find tickets page']
       ],
      :vouchers => [
        ['/list', "Voucher list"],
        ['/checkout?options_cart_contains_vouchers=1', "Customer Details and Recipients"],
        ['/confirmation?options_cart_contains_vouchers=1', "Confirmation Page"]
       ]
    }
    
    return st[template_type.to_sym]
  end

	def options_for_action
		
	end

  def listify_docs(docs)
    result = ["<ul>"]
    docs.sort.each do |key, val|
      result << "<li>"
      val = key == 'syntax' ? "<pre><code> #{val} </code></pre>" : val
      key = key == 'description' ? '' : key
      result <<  "<span>#{key}</span> #{val.kind_of?(Hash) ? listify_docs(val) : val}"
      result << "</li>"
    end
    
    result << "</ul>"
  end
  
  def load_docs_database
    YAML.load(File.read("#{ROOT}/db/docs.yml"))
  end
  
  def options_for_javascript(options)
    '{' + options.map {|k, v| "#{k}:#{v.kind_of?(Hash) ? options_for_javascript(v) : "'#{v}'"}"}.sort.join(', ') + '}'
  end
  
  def render_as_js_string(name, html)
    result = []
    
    result << %|var #{name} = ''+|
    result << html.to_a.collect do |line|
      %|\t\'#{line.chomp}\'+\n|
    end
    result << %|\t'';|
    result.to_s
  end
  
  def escape_javascript(javascript)
    (javascript || '').gsub(/\r\n|\n|\r/, "\\n").gsub(/["']/) { |m| "\\#{m}" }
  end
  
  def path_scan
    if @request.path_info =~ /(\w+)\.(js|css)/
      @action_name = "#{$1}_#{$2}"
    else
      raise NotFoundError
    end
  end

  
  private
  
  def current_template
  	template_cookie ? template_cookie.value : @params['action']
	end
  
  def theme_cookie
    @request.cookies.find { |c| c.name == 'theme' }
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
		return default_template_type
	end
	
	def default_template_type
		default = :rooms if template_types_for_view.keys.include? :rooms
		default = template_types_for_view.keys.first.to_s
		cookie = WEBrick::Cookie.new('template_type', default)
    cookie.path = '/'
    @response.cookies.push(cookie)
    return default
	end

  def template_cookie
    @request.cookies.find { |c| c.name == "template_#{@params['action']}" }
  end
  
  def theme_template_path
    "#{THEMES}/#{theme_cookie.value}/templates"
  end
  
end

