class CustomerDrop < Liquid::Drop
  
  def initialize(customer)
    @customer = customer
  end
  
  def errors
    @customer.errors
  end
  
  def company_name
    @customer.name
  end
  
  def name
    @customer.fullname
  end
  
  def email
    return @customer.email if @customer.main_contact.nil?
    return @customer.main_contact.email if @customer.email.empty?
    @customer.email
  end
  
  def phone
    @customer.phone
  end
  
  def city
    @customer.city
  end
  
  def address1
    @customer.address1
  end
  
  def address2
    @customer.address2
  end
  
  def postcode
    @customer.postcode
  end
  
  def country
    @customer.country
  end
  
  def terms_conditions
    return @customer.terms_conditions unless @customer.nil? or @customer.terms_conditions.nil?
    return ""
  end
  
  def country_options_for_select
    countries = ["Please select something", "Ireland", "England", "Scottland"]
    tag = ""
    for country in countries
    	tag << '<option value="' + country.downcase + '">' + country + '</option>'
    end
    return tag
  end
  
  def contacts
    @customer.contacts.collect{|x| ContactDrop.new(x)}
  end
  
  def contact_phone
    @customer.contacts.first.phone rescue @customer.phone
  end
  
end
