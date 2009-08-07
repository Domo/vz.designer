class CustomerSettingDrop < Liquid::Drop
  
  def initialize(_customer_setting)
    @customer_setting = _customer_setting
  end
  
  def terms_conditions
    return "no settings present!!!" if @customer_setting.nil?
    @customer_setting.terms_conditions
  end
  
  def booking_fee
	  return "no settings present!!!" if @customer_setting.nil?
	  @customer_setting.booking_fee
  end
end

