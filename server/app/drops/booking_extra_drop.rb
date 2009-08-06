class BookingExtraDrop < Liquid::Drop
  def initialize(source)
    @source = source
  end

  def id
    @source.extra.id
  end

  def name
    @source.extra.name
  end 

  def short_description
    @source.extra.short_description
  end

  def short_description_2
    @source.extra.short_description_2
  end

  def contact_name
    @source.contact.fullname
  end
  
  def contact_id
    @source.contact.id
  end
end
