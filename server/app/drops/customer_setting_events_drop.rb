class CustomerSettingEventsDrop < Liquid::Drop
  
  def initialize(_customer_setting, event)
    @customer_setting = _customer_setting
    @event = event
  end
  
  def terms_conditions
    return @event.terms_and_conditions if not @event.terms_and_conditions.nil? and not @event.terms_and_conditions.empty?
    return "no settings present!" if @customer_setting.nil?
    @customer_setting.terms_conditions
  end
end

