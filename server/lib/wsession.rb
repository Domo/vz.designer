class WSession
	
	cattr_accessor :current_template
	
	#'Session'-Funktionen
	
	def self.theme
		cookie = $request.cookies.find { |c| c.name == 'theme' }
		return cookie.value
	end
	
	#Important: It's really just the id, not an object like in vz.rooms!
	def self.property
		cookie = $request.cookies.find { |c| c.name == 'property' }
		p_id = cookie.value rescue 1
		return Database.find(p_id, :properties)
	end
	
	#shortcuts and ähnliches
	
	def self.theme_path
		File.join(THEMES, self.theme, "")
	end
	
	def self.get_theme_file(file)
		if File.exists? file
			content = File.read(file)
			puts "File loaded: " + file
		else
			puts "File not found: " + file
			content = "Not found."
		end
		ext = file.split(".").last
		return {:content => content, :mime_type => self.mime_types(ext)}
	end
	
private

	def self.mime_types(ext)
		types = {
			:css => "text/css",
			:js => "text/javascript",
			:png => "image/png",
			:gif => "image/gif",
			:jpg => "image/jpeg",
			:jpeg => "image/jpeg"
		}
		return types[ext.to_sym]
	end
	
end