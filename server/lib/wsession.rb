module WSession
	
	#'Session'-Funktionen
	
	def self.theme
		cookie = $request.cookies.find { |c| c.name == 'theme' }
		return cookie.value
	end
	
	#Important: It's really just the id, not an object like in vz.rooms!
	def self.property_id
		cookie = $request.cookies.find { |c| c.name == 'property' }
		p_id = cookie.value rescue ""
		return {:id => p_id}
	end
	
	#shortcuts and ähnliches
	
	def self.theme_path
		File.join(THEMES, self.theme, "")
	end
	
	def self.get_theme_file(file)
		puts "File: " + file
		file = File.join(self.theme_path, file)
		if File.exists? file
			content = File.read(file)
		else
			content = ""
		end
		ext = file.split(".").last
		return {:content => content, :mime_type => self.mime_types(ext)}
	end
	
private

	def self.mime_types(ext)
		types = {
			:css => "text/css",
			:js => "text/javascript"
		}
		return types[ext.to_sym]
	end
	
end