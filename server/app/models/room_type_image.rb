class RoomTypeImage
	require 'database'
	
	attr_accessor :id
	
	def initialize
		
		types = ["geometry", "geomety", "large", "medium", "normal", "thumb", "thumbnail"]
		
		files = Dir.glob(ROOT + "/public/roomimages/*.*")
		images = []
		begin
			for filename in files
				next if types.include? filename.split("/").last.split(".").first.split("_").last
				images << "/roomimages/" + filename.split("/").last
			end
		rescue
		end
		self.id = rand(images.size)
		@image = images[self.id]	
	
	end
	
	def public_filename(thumbnail = 'geomety')
		get_thumbnail(thumbnail)
	end
	
	def has_child?(type)
		true
	end
	
private
	
	def get_thumbnail(type)
		i = @image.split('.')
		return @image.gsub('.' + i.last, '_' + type) + '.' + i.last
	end
	
end