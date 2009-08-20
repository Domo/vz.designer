require 'servlet'
require 'wsession'

class LiquidServlet < Servlet
  
  protected
    
  def render_file(file, options)
    content = File.read(file).gsub('!= blank', "!= ''")
    if file =~ /skin.liquid/
      raise "The layout is missing the required {{ content_for_header }} in the html head" unless content =~ /content_for_header/
      raise "The layout is missing the required {{ content_for_layout }} in the body part" unless content =~ /content_for_layout/      
    end
    template_path = file
    while template_path.split("/").last != "templates"
    	template_path = template_path.gsub("/" + template_path.split("/").last, "")
    end
    
    f = file.split("/").last.split(".").first
    unless file.include? "modules" or f == 'skin'
	    WSession.current_template = f
	  end
    
    if file =~ /skin.liquid/
    	Liquid::Template.file_system = Liquid::LocalFileSystem.new(template_path)
    end
    template = Liquid::Template.parse(content)
    template.render(assigns, :registers => {:request => @request, :controller => self })              
  end
  
end