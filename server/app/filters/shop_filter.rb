require 'wsession'

module ShopFilter
	      
  def asset_url(input)
    "/files/shops/random_number/assets/#{input}"
  end

  def global_asset_url(input)
    req = @context.registers[:request]
    "http://#{req.host}:#{req.port}/global/#{input}"
  end
  
  def shopify_asset_url(input)
    "/shopify/#{input}"
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
	  File.join("http://assets.visrez.com", "roomsandevents/common", version, input)
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
