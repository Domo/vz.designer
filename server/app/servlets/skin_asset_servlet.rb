require 'servlet'
require 'wsession'

class SkinAssetServlet < Servlet      

  def index
  	file = "#{theme_path}#{@params['file']}"
  	file = file.gsub("/", "\\") if RUBY_PLATFORM.include?("win")
		# rfile = WSession.get_theme_file(file)
		# 		content = rfile[:content]
		# 		@response['Content-Type'] = rfile[:mime_type]
		# 		render :text => content
		@response['Content-Type'] = mime_types[File.extname(file)[1..-1]]         
      File.open(file, "rb") do |fp|
   			render :text => fp.read
      end
	end 
  
  protected
  
  def theme_path
  	File.join(THEMES, @theme)
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

