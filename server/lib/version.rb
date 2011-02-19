require 'open-uri'

module Vision
  extend self
  
  attr_accessor :version
  attr_accessor :latest_version
  attr_accessor :server_path
  
  def uptodate?
  	if self.latest_version
    	self.version >= self.latest_version	
    end
  end

  def verify_latest_version
  	begin
	   f = open(self.server_path, "User-Agent" => "Ruby/#{RUBY_VERSION}")
		 self.latest_version = f.string
		rescue
			self.latest_version = self.version
		end		
  end
end

Vision.version        = '4.3.0'
Vision.server_path		= 'http://admin.middleeu.visrez.com/queries/vision_version'
