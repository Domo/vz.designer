require 'servlet'

class ThemePickerServlet < Servlet      
	
	def my_name
		"theme_picker"
	end

  def choose    
    cookie = WEBrick::Cookie.new('theme', @params['theme'].to_s)
    cookie.path = '/'
    @response.cookies.push(cookie)
    
    
    cookie = WEBrick::Cookie.new('template_type', "")
    cookie.path = '/'
    @response.cookies.push(cookie)
    
    redirect_to '/'
  end
  
  def index
    @themes = available_themes
  end
  
  def zip_theme
    theme = @params['theme']
        
	  name = @params['name'].to_s
    description = @params['description'].to_s
    
    skin_info = {:description => description, :name => name}
    
    yml_file = File.join(THEMES, theme, 'info.yml')
    a = File.new(yml_file, "w+")
			a.puts(YAML.dump(skin_info))
		a.close
        
    location = "#{ROOT}/../exports/#{theme}.zip"
    
    zip(theme, location) do |zip|
      
      content = zip.read
    
      @response['Content-Type'] = 'application/zip'
      @response['Content-disposition'] = "attachment; filename=#{theme}.theme.zip"
      @response['Content-Length'] = content.size

      render :text => content, :status => "200 Found"                    
    end
    
  end
  
  def create_theme
        
    unless @params['from'] and @params['to']
      @message = "Didn't get all required arguments: from '#{@params['from']}', to '#{@params['to']}'..."
      return
    end

    if @params['from'].empty? or @params['to'].empty?
      @message = "Didn't get all required arguments: from '#{@params['from']}', to '#{@params['to']}'..."
      return
    end
    
    to_param = @params['to'].gsub(/[ !"§$%&()=+]/, "_")
    
    from  = THEMES + "/#{@params['from']}"
    to    = THEMES + "/#{to_param}"    
    
    if not File.exist?(from)
      @message = 'Source theme does not exist...'
      return 
    end
    if File.exist?(to)
      @message = 'Target theme already exists...'
      return 
    end
    
    FileUtils.cp_r(from, to)
    
    case @params['type']
  	when "rooms"
  		FileUtils.rm_rf(to + '/templates/tickets')
  		FileUtils.rm_rf(to + '/templates/golf')
  		FileUtils.rm_rf(to + '/templates/vouchers')
		when "events"
			Dir[to + '/templates/*.liquid'].each do |rooms_template|
				FileUtils.rm_rf(rooms_template)
			end
			FileUtils.rm_rf(to + '/templates/static')
			cookie = WEBrick::Cookie.new('template_type', 'events')
	    cookie.path = '/'
	    @response.cookies.push(cookie)
		end

    Dir[to + '/**/.svn'].each do |svndir|
      FileUtils.rm_rf(svndir)
    end
    
    cookie = WEBrick::Cookie.new('theme', to_param)
    cookie.path = '/'
    
    @response.cookies.push(cookie)
        
    redirect_to '/'
  end
  
  def export  
    @theme = @params['theme'] 
  end
  
  def export_theme
    @theme = @params['theme']
  end
  
  def update_readme
    @theme = @params['theme']    
    
    File.open(THEMES + "/#{@theme}/README", 'w+') do |fp|
      fp << @params['readme']
    end
    
    @readme = @params['readme']
    render :action => "export_theme"
  end
  
  def create
    @themes = available_themes
  end
  
  def common_assets
  	@v = 'v_003'
  	@assets = Dir[ROOT + "/public/common/" + @v + "/**/*"]
  	@assets = @assets.map {|x| x.gsub(ROOT + "/public/common/" + @v + "/", "") unless File.directory? x}.compact
	end
	
	def get_available_template_types
		skin = @params['from']
		skin_dir = File.join(THEMES, skin)
		options = []
		if File.exists? File.join(skin_dir, "templates", "skin.liquid")
			options << create_option("Rooms", "rooms")
		end
		if File.exists? File.join(skin_dir, "templates", "tickets")
			options << create_option("Events", "events")
		end
		if options.size == 2
			options << create_option("Rooms and Events", "roomsevents")
		end
		options = options.join
		render :text => options
	end
	
	def get_skin_info
		skin = @params['from']
		skin_dir = File.join(THEMES, skin)
		info_file = YAML::load(File.open(File.join(skin_dir, 'info.yml'))) rescue ""
		skin_info_description = ""
	  if info_file
		  skin_info_name = info_file[:name] || skin
		  skin_info_description = info_file[:description] || ''
	  end
	  tag = '<span class="caption">Name:</span><br />' + skin_info_name
	  tag += "<br />"
	  tag += '<span class="caption">Description:</span><br />' + skin_info_description
	  render :text => tag
	end
    
  private
  
  def create_option name, option
  	'<option value="' + option + '">' + name + '</option>'
	end
  
  def available_themes
    Dir[THEMES + '/*'].collect do |theme|
      next unless File.directory?(theme)
      File.basename(theme)
    end.compact
  end
  
  def theme_cookie
    @request.cookies.find { |c| c.name == 'theme' }
  end
  
  def zip(theme, location)
  	theme_path = File.join(THEMES, theme)
    
    begin      
      FileUtils.mkdir_p(File.dirname(location))
      FileUtils.rm(location) if File.exists?(location)
      
      if RUBY_PLATFORM =~ /darwin/
        
        Dir.chdir(THEMES) do      
          system("zip -r \"#{location}\" #{theme}/ -x \"*.svn*\" -x \"*.git*\"")
        end
        
      else
				Zip::ZipFile::open(location, true) { |zf|
					Dir[theme_path + '/**/*'].each { |f| zf.add(f.gsub(theme_path + "/", ""), f) }
				}
      end
                  
      File.open(location, "rb") { |fp| yield fp }
              
    rescue
      FileUtils.rm(location) if File.exists?(location)
      raise
    end
  end
  
end

