class PropertyDrop < Liquid::Drop
  
  attr_accessor :property
  
  def initialize(_property)
    @property = _property
  end
  
  def has_rates
    true
  end
  
  def id
    @property.id
  end
  
  def name
    @property.name
  end
  
  def shortcut
    @property.shortcut
  end
  
  def terms_and_conditions
	  @property.terms_and_conditions
  end
  
  def description
    @property.property_description
  end
  
  def image_tag
    return "" if @property.images.length == 0
    '<img src="' + @property.images.first.public_filename('normal') + '" alt="' + @property.name + '"/>' rescue ''
  end    
  
  def image_tags
    text = ""
    for image in @property.images
      text << '<img src="' + image.public_filename('normal') +'" alt="' + @property.name + '" />'
    end
    text
  end
  
  def custom_tag
    return "" if @property.images.length == 0
    '<img src="' + @property.images.first.public_filename('custom') + '" alt="' + @property.name + '"/>' rescue "no custom image."
  end  
  
  def custom_image
    return "" if @property.images.length == 0
    @property.images.first.public_filename('custom') rescue "" 
  end  
  
  def property_select_options
    helper.options_for_select(Property.find_all_for_select_options, (@property.id rescue nil))
  end
  
end
