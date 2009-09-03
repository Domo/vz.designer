require 'open-uri'
require 'rexml/document'

module Vision
  extend self
  
  attr_accessor :version
  attr_accessor :latest_version
  attr_accessor :server_path
  
  def uptodate?
    self.version >= self.latest_version
  end

  def verify_latest_version
    Thread.new do
      begin
       f = open("http://www.zu-untersuchende-seite","User-Agent" => "Ruby/#{RUBY_VERSION}")
			 self.latest_version = f 
      rescue 
      end
    end
  end
end

Vision.version        = '4.0.1'
Vision.server_path		= 'localhost/queries/vision_version'

