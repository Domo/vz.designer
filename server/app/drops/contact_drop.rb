class ContactDrop < Liquid::Drop
  
  def initialize(contact, values = {})
    @contact = contact
    @values = values
  end
  
  def selected_extra
    return 0 if @values[:selected_extra].nil?
    @values[:selected_extra].id
  end
  
  def errors
    @contact.errors
  end
  
  def first_name
    @contact.first_name
  end
  
  def last_name
    @contact.last_name
  end
  
  def full_name
    first_name + " " + last_name
  end
  
  def email
    @contact.email
  end
  
  def id
    @contact.id rescue 0
  end
  
  def phone
    @contact.phone
  end

  def fax
    @contact.fax
  end
  
  def ezine
    @contact.ezine == true ? 'Yes' : 'No'
  end
  
  def position
    @contact.position
  end
  
  # Creates ErrorDrops for all available errors on this contact
  #----------------------------------------------------------------------------
  def field_errors
    @contact.errors.map {|e| ErrorDrop.new(e)}
  end
  
  def has_errors
    return (not @contact.errors.empty?)
  end
  
end
