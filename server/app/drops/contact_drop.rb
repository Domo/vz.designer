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
  
end
