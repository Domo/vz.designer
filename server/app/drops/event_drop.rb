class EventDrop < Liquid::Drop
  attr_accessor :equipment
  
  def initialize(_event, _first_day=[])
    @event = _event
    
    for date in _first_day
      @first_day = date if @first_day.nil? or @first_day > date
    end
  end
  
  def image_tag
    return "" if @event.images.length == 0
    '<img src="' + @event.images.first.public_filename('normal') + '" alt="' + @event.name + '"/>'
  end      

  def has_image
    @event.images.length > 0
  end

  def thumb_tag
    return "" if @event.images.length == 0
    '<img src="' + @event.images.first.public_filename('geomety') + '" alt="' + @event.name + '"/>'
  end 
  
  def custom_tag
    return "" if @event.images.length == 0
    '<img src="' + @event.images.first.public_filename('custom') + '" alt="' + @event.name + '"/>' rescue "no custom image."
  end  
  
  def custom_image
    return "" if @event.images.length == 0
    @event.images.first.public_filename('custom') rescue "" 
  end
  
  def thumbnail_image
    return "" if @event.images.length == 0
    @event.images.first.public_filename('thumb')
  end  
  
  def name
    @event.name
  end

  def location
    @event.location
  end

  def description
    @event.description
  end  

  def short_description
    @event.description
  end 
  
  def id
    @event.id
  end
  
  #used for golf
  def days
     @event.event_availabilities.collect{|x| EventAvailabilityDrop.new(x)}
  end
  
  def first_day
    @first_day.to_date
  end  
  
  def terms_and_conditions
    return CustomerSetting.first.terms_conditions.gsub("\n",'<br />') if @event.terms_and_conditions.nil? or @event.terms_and_conditions.blank?
	  @event.terms_and_conditions.gsub("\n",'<br />')
  end
  
  def rate_codes
    bundles = @event.ticketbundles
    rates = bundles.collect{|x| x.rate}.compact
    rates = rates.collect{|x| x.code}.uniq.compact
  end

  def rate_codes_string
    rate_codes.join("|")
  end  
end
