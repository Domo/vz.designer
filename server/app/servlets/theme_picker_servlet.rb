require 'servlet'
require 'version'

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
    Vision.verify_latest_version
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
    
    params = correct_hashed_params

    #Delete all Files which are not used in the current system
    unless params["functions"].keys.include? "rooms"
      Dir[to + '/templates/*.liquid'].each do |rooms_template|
        FileUtils.rm_rf(rooms_template)
      end
      FileUtils.rm_rf(to + '/templates/modules/_availability.liquid')
      FileUtils.rm_rf(to + '/templates/modules/_search.liquid')
      FileUtils.rm_rf(to + '/templates/modules/_visualnav.liquid')
      FileUtils.rm_rf(to + '/templates/static')
    end
    
    unless params["functions"].keys.include? "events"
  		FileUtils.rm_rf(to + '/templates/tickets')
  		Dir[to + '/templates/modules/_tickets_*.liquid'].each do |events_module|
        FileUtils.rm_rf(events_module)
      end
  	end
  	
  	unless params["functions"].keys.include? "vouchers"
  	  FileUtils.rm_rf(to + '/templates/vouchers')
  	  Dir[to + '/templates/modules/_vouchers_*.liquid'].each do |voucher_module|
        FileUtils.rm_rf(voucher_module)
      end
  	end
  	
  	unless params["functions"].keys.include? "golf"
  	  FileUtils.rm_rf(to + '/templates/golf')
  	end
  	
		cookie = WEBrick::Cookie.new('template_type', params["functions"].keys.first)
	  cookie.path = '/'
	  @response.cookies.push(cookie)

    #Delete the info file and the thumbnail, the new skin should get its own
		FileUtils.rm_rf(to + '/images/thumbnail.png')
		FileUtils.rm_rf(to + '/info.yml')
    
    #Eventuelles SVN-Verzeichnis loeschen
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
  
  def create
    @themes = available_themes
  end
  
  def common_assets
  	@v = 'v_003'
  	@assets = Dir[ROOT + "/public/common/" + @v + "/**/*"]
  	@assets = @assets.map {|x| x.gsub(ROOT + "/public/common/" + @v + "/", "") unless File.directory? x}.compact
	end
	
	# Creates an array with all available template functions
	#----------------------------------------------------------------------------
	def get_available_template_types
		skin = @params['from']
		skin_dir = File.join(THEMES, skin)
		options = []
		if File.exists? File.join(skin_dir, "templates", "skin.liquid")
			options << create_checkbox("functions", "rooms", "Rooms", "validate-one-required")
		end
		if File.exists? File.join(skin_dir, "templates", "tickets")
			options << create_checkbox("functions", "events", "Events", "validate-one-required")
		end
		if File.exists? File.join(skin_dir, "templates", "vouchers")
		  options << create_checkbox("functions", "vouchers", "Vouchers", "validate-one-required")
		end
		options = options.join("<br />")
		render :text => options
	end
	
	def get_skin_info
		skin = @params['from']
		skin_dir = File.join(THEMES, skin)
		info_file_path = File.join(skin_dir, 'info.yml')
		info_file = YAML::load(File.open(info_file_path)) rescue ""
		skin_info_description = ""
	  if info_file
		  skin_info_name = info_file[:name] || skin
		  skin_info_description = info_file[:description] || "None, yet"
	  end
	  tag = '<span class="caption">Name:</span><br />' + skin_info_name
	  tag += "<br />"
	  tag += '<span class="caption">Description:</span><br />' + skin_info_description
	  
	  thumbnail = File.join(skin_dir, "images", "thumbnail.png")
		if File.exists? thumbnail
			tag += "<br />"
			tag += '<span class="caption">Thumbnail:</span><br />'
			thumbnail_url = '/dashboard/get_skin_thumbnail?skin=' + skin
			modalbox_code = '/dashboard/show_skin_thumbnail?skin=' + skin
			modalbox = "Modalbox.show('" + modalbox_code + "', {title: 'Thumbnail', width: 750});"
			tag += '<img src="' + thumbnail_url +'" onclick="' + modalbox + '">'
		end
		tag += '<p>This skin has no info-file yet. It will be created when you export the skin.</p>' unless File.exists? info_file_path
	  render :text => tag
	end
	
	def show_skin_thumbnail
		skin = @params['skin']
		@thumbnail = '/dashboard/get_skin_thumbnail?skin=' + skin
	end
	
	def get_skin_thumbnail
		skin_dir = File.join(THEMES, @params['skin'])
		file = "#{skin_dir}/images/thumbnail.png"
  	file = file.gsub("/", "\\") if RUBY_PLATFORM.include?("win")
  	
		@response['Content-Type'] = mime_types[File.extname(file)[1..-1]]         
      File.open(file, "rb") do |fp|
   			render :text => fp.read
      end
	end

#------------------------------------------------------------------------------------------------------------------------------------------------
                                                                       private
#------------------------------------------------------------------------------------------------------------------------------------------------
  
  # This server does not create hashes from params like functions[function] = 1
  #----------------------------------------------------------------------------
  def correct_hashed_params
    params = {}
    @params.each do |key, value|
      if key.scan(/([a-zA-Z]*)\[([a-zA-Z]*)\]/).size > 0
        r = key.scan(/([a-zA-Z]*)\[([a-zA-Z]*)\]/).first
        params[r.first] = {} if params[r.first].nil?
        params[r.first][r.last] = value
      else
        params[key] = value
      end
    end
    return params
  end
  
  def create_option name, option
  	'<option value="' + option + '">' + name + '</option>'
	end
	
	def create_checkbox(name, value, caption, classnames = "")
	  "<input type=\"checkbox\" name=\"#{name}[#{value}]\" value=\"1\" class=\"#{classnames}\" />#{caption}"
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

