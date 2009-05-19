require 'servlet'
require 'wsession'

class SkinAssetServlet < Servlet      

  def index
  	file = "#{template_path}#{@params['file']}"
		rfile = WSession.get_theme_file(file)
		content = rfile[:content]
		@response['Content-Type'] = rfile[:mime_type]
		render :text => content
	end 
  
  protected
  
  def template_path
    "#{THEMES}/#{@theme}"
  end
  
  def before_filter
    cookie = @request.cookies.find { |c| c.name == 'theme' }
    
    if cookie.nil?
      redirect_to '/dashboard/'
    end
    
    @theme = cookie.value
  end

  
  def path_scan
    @params['file'] = @request.path_info    
    @action_name = 'index'      
  end
  
  private
  
  def extra(str)
    str
  end
  
  
end

