require 'wsession'

module VisrezFilter
	
	def format_decimal(input)    
   return "0" if input.nil?
   
   parts = input.to_s.split('.')
   if parts.length == 1
     parts[1] = "00"
   end
   
   if parts[1].length == 1
     parts[1] = parts[1] + "0"
   end
   
   if parts[1].length > 2
     parts[1] = parts[1][0..1]
   end  
   
   return parts.join(".")
 end 
 
  def format_without_decimal(input)
    return "0" if input.nil?
    parts = input.to_s.split('.')
    return parts[0]  
  end
 
  def with_new_lines(input)
    return input.to_s.gsub(/\n/, '<br />')# rescue ""
  end
  		
  
  def ready_for_javascript(input)
	  new_input = input
	  new_input = new_input.to_s.gsub(/\r/, '')
	  new_input = new_input.to_s.gsub(/[']/, '\\\\\'')
	  new_input = new_input.to_s.gsub(/["]/, '&quot;')
	  new_input = new_input.to_s.gsub(/\n/, "")
	  return new_input
  end
	      
  def asset_url(input)
    "/skin/#{input}"
  end

  def common_asset_url(input, version = "v_001")
    common_asset(input, version)
  end
  
  def script_tag(url)
    %(<script src="#{url}" type="text/javascript"></script>)
  end

  def stylesheet_tag(url, media="all")
    %(<link href="/skin/stylesheets/#{url}.css" rel="stylesheet" type="text/css"  media="#{media}"  />)
  end
  
  def style_sheet(url, media="screen,projection")
  	stylesheet_tag(url, media)
  end
  
  def common_asset(input, version = "v_001")
	  # File.join("http://assets.visrez.com", "roomsandevents/common", version, input)
	  req = @context.registers[:request]
    "http://#{req.host}:#{req.port}/common/#{version}/#{input}"
  end
  
  def	google_include(input)
	  '<script src="http://'+ get_google_include(input) + '" type="text/javascript"></script>'
  end
       
  def link_to(link, url, title="")
    %|<a href="#{url}" title="#{title}">#{link}</a>|
  end
  
  def img_tag(url, alt="")
    %|<img src="#{url}" alt="#{alt}" />|  
  end  
  
  def link_to_vendor(vendor)
    if vendor
      link_to vendor, url_for_vendor(vendor), vendor
    else
      'Unknown Vendor'
    end
  end
  
  def link_to_type(type)
    if type
      link_to type, url_for_type(type), type
    else
      'Unknown Vendor'
    end
  end
  
  def url_for_vendor(vendor_title)
    "/collections/#{vendor_title.to_handle}"
  end
  
  def url_for_type(type_title)
    "/collections/#{type_title.to_handle}"
  end
  
  def product_img_url(url, style = 'small')
    
    unless url =~ /^products\/([\w\-\_]+)\.(\w{2,4})/
      raise ArgumentError, 'filter "size" can only be called on product images'
    end
    
    case style
    when 'original'
      return '/files/shops/random_number/' + url 
    when 'grande', 'large', 'medium', 'small', 'thumb', 'icon'
      "/files/shops/random_number/products/#{$1}_#{style}.#{$2}"              
    else
      raise ArgumentError, 'valid parameters for filter "size" are: original, grande, large, medium, small, thumb and icon '      
    end
  end
  
  def default_pagination(paginate)
    
    html = []    
    html << %(<span class="prev">#{link_to(paginate['previous']['title'], paginate['previous']['url'])}</span>) if paginate['previous']

    for part in paginate['parts']

      if part['is_link']
        html << %(<span class="page">#{link_to(part['title'], part['url'])}</span>)        
      elsif part['title'].to_i == paginate['current_page'].to_i
        html << %(<span class="page current">#{part['title']}</span>)        
      else
        html << %(<span class="deco">#{part['title']}</span>)                
      end
      
    end

    html << %(<span class="next">#{link_to(paginate['next']['title'], paginate['next']['url'])}</span>) if paginate['next']
    html.join(' ')
  end
  
  # Accepts a number, and two words - one for singular, one for plural
  # Returns the singular word if input equals 1, otherwise plural
  def pluralize(input, singular, plural)
    input == 1 ? singular : plural
  end
  
  # Helper method to create an ajax responder
  #----------------------------------------------------------------------------
  def ajax_responder(onCall, onComplete)
    js = "<script type=\"text/javascript\">"
    js << "Ajax.Responders.register({"
    js << "onCreate: function() {"
    js << onCall
    js << "},"
    js << "onComplete: function() {"
    js << onComplete
    js << "}});"
    js << "</script>"
    
    return js
  end
  
  # creates a form validation with default options for the given form id
  #----------------------------------------------------------------------------
  def javascript_validation(form_id, options = "immediate: true")
    tag = <<-eos 
        new Validation('#{form_id}', {#{options}});
    eos
  end
  
  # Creates field focus color changing effects for the given form
  #----------------------------------------------------------------------------
  def field_focus_colors(form_id)
    '"CreateFieldFocusColorChanges("#{form_id}");'    
  end
  
  # Renders the given flashdrop
  #----------------------------------------------------------------------------
  def render_flash(flash, element_type = "h2")
    def start_tag(t, element_type)
      "<#{element_type} class=\"flash-#{t}\">"  
    end
    
    end_tag = "</#{element_type}>"
    tag = ""

    unless flash.notice.blank?
      tag += start_tag("notice", element_type) + flash.notice + end_tag
    end
    unless flash.warning.blank?
      tag += start_tag("warning", element_type) + flash.warning + end_tag
    end 
    unless flash.error.blank?
      tag += start_tag("error", element_type) + flash.error + end_tag
    end  
    
    return tag
  end
  
  private
  
  def get_google_include(wanted)
	  includes = {
			:prototype => "ajax.googleapis.com/ajax/libs/prototype/1.6.0.3/prototype.js",
			:scriptaculous => "ajax.googleapis.com/ajax/libs/scriptaculous/1.8.2/scriptaculous.js",
			:jquery => "ajax.googleapis.com/ajax/libs/jquery/1.3.1/jquery.min.js",
			:mootools => "ajax.googleapis.com/ajax/libs/mootools/1.2.1/mootools-yui-compressed.js",
			:yui => "ajax.googleapis.com/ajax/libs/yui/2.6.0/build/yuiloader/yuiloader-min.js"
	  }
	  return includes[wanted.to_sym]  	
  end
      
end
