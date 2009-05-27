class RateSearchItemDrop < Liquid::Drop
  def initialize(_item, _with_breakfast=false)
    @rate_search_container_item = _item
  end    
  
  def rate_name
    @rate_search_container_item.rate_room_type.rate.name
  end
  
  def rate_description
    @rate_search_container_item.rate_room_type.rate.description
  end
  
  def package_description
    @rate_search_container_item.rate_room_type.rate.restriction_text
  end
  
  def room_type_name
    @rate_search_container_item.rate_room_type.room_type.name
  end
  
  def rate_room_type_id
    @rate_search_container_item.rate_room_type.id
  end
  
  def maximum_occ
    @rate_search_container_item.maximum_occ
  end
  
  #select tag for events, if there are more than 1 possible days
  def select_event
    options = []
    return "" if not @rate_search_container_item.rate_room_type.rate.is_ticket_rate?  

    event_days = @rate_search_container_item.rate_room_type.rate.possible_event_days(@rate_search_container_item.rate_search_container.arrival_date, @rate_search_container_item.rate_search_container.nights, (@rate_search_container_item.rate_search_container.adults + @rate_search_container_item.rate_search_container.children))
    
    #return arrival date if there is only one item in the list
    return event_days.first.to_s(:eu) if event_days.length == 1
    
    options = []
    for d in event_days
        selected = ""
        selected = " selected=\"selected\" " if not @rate_search_container_item.event_day.nil? and d.to_date.to_s(:eu) == @rate_search_container_item.event_day.to_date.to_s(:eu)
      options << '<option  value="' + d.to_date.to_s(:eu) + '" ' + selected + '>' + d.to_date.to_s(:eu) + "</option>" 
    end
    
    select = "<select name=\"event_day\" id=\"events_#{self.id}\" class=\"medium_select\">" + options.join + "</select>"
    script = generate_observer :events
    return select + script
  end

  #select tag for adults, including ajax
  def select_adults   
      select = "<select name=\"adults\" id=\"adults_#{self.id}\" class=\"small_select\">" + build_adult_options.join + "</select>"
      script = generate_observer :adults 
      return select + script
  end

  #select tag for children, including ajax
  def select_children
      select = "<select name=\"children\" id=\"children_#{self.id}\" class=\"small_select\">" + build_children_options.join + "</select>"
      script = generate_observer :children 
      return select + script    
  end

  def build_adult_options
    options = []
    #make sure, the room can not contain more people then set in the rate
    rate_room_type = @rate_search_container_item.rate_room_type
    maximum = rate_room_type.maximum_occ

    min = self.min_adults  
    max = self.max_adults
    
    for n in (min..max).to_a
      next if (maximum - children - n) < 0
      selected = ""
      selected = " selected=\"selected\" " if n == self.adults
      options << "<option value=\"#{n}\" #{selected}>" + n.to_s + "</option>"
    end 
    options 
  end

  def build_children_options
     options = []
    #make sure, the room can not contain more people then set in the rate
    rate_room_type = @rate_search_container_item.rate_room_type
    maximum = rate_room_type.maximum_occ

    for n in (self.min_children..self.max_children).to_a
      next if (maximum - adults - n) < 0
      selected = ""
      selected = " selected=\"selected\" " if n == self.children
      options << "<option value=\"#{n}\" #{selected}>" + n.to_s + "</option>"
    end  
    
    options
  end

  def show_breakfast
    @rate_search_container_item.rate_room_type.rate.show_breakfast_option
  end

  #select tag for breakfast, including ajax 
  def select_breakfast
      options = []

      #show breakfast options?
      return "-" if not @rate_search_container_item.rate_room_type.rate.show_breakfast_option
      
      selected = ""
      selected = " selected=\"selected\" " if self.with_breakfast == 1 or @rate_search_container_item.rate_room_type.rate.breakfast_included
      options << "<option value=\"1\" #{selected}>Yes</option>"
      
      if not @rate_search_container_item.rate_room_type.rate.breakfast_included
        selected = ""
        selected = " selected=\"selected\" " if self.with_breakfast == 0
        options << "<option value=\"0\" #{selected}>No</option>"
      end    
      select = "<select name=\"breakfast\" id=\"breakfast_#{self.id}\" class=\"small_select\">" + options.join + "</select>"
      script = generate_observer :breakfast 
      return select + script  
  end
  
  def generate_adults_observer
    generate_observer :adults
  end

  def generate_children_observer
    generate_observer :children
  end
  
  def generate_breakfast_observer
    generate_observer :breakfast
  end
  
  def generate_observer identifier
      script = "<script type=\"text/javascript\">" +
               "Event.observe($('#{identifier}_#{self.id}'), 'change', function() { " +  
               "new Ajax.Request('ajax_update_room', {asynchronous:true, evalScripts:true, parameters:Form.serialize($('room_form_#{self.id}')), onCreate:function(request){Element.show('loading_#{self.id}');}, onComplete:function(request){Element.hide('loading_#{self.id}');} });});</script>"
               #"new Ajax.Request('rjstest', {asynchronous:true, evalScripts:true, parameters:Form.serialize($('room_form_#{self.id}')), onCreate:function(request){Element.toggle('loading_#{self.id}');}});});</script>"       
      return script
  end  
  private :generate_observer
  
  def price
    @rate_search_container_item.price
  end
  
  def min_adults
    #calculate minimum number of adults for corresponding room_type
	return @rate_search_container_item.rate_room_type.rate.min_occ if @rate_search_container_item.rate_room_type.rate.min_occ > 0 and @rate_search_container_item.rate_room_type.rate.restrictions_active
	return @rate_search_container_item.rate_room_type.rate.number_of_adults @rate_search_container_item.rate_room_type, 1
  end
  
  def max_adults
    return @rate_search_container_item.rate_room_type.rate.max_adults if @rate_search_container_item.rate_room_type.rate.max_adults > 0 and @rate_search_container_item.rate_room_type.rate.restrictions_active
    return @rate_search_container_item.rate_room_type.room_type.adults
  end  
  
  def max_children
    rate = @rate_search_container_item.rate_room_type.rate
    
    max_room = @rate_search_container_item.rate_room_type.room_type.max_children
    max_rate = rate.max_children
    max_rate = max_room if max_rate > max_room
    
    return max_rate if rate.restrictions_active
    max_room
  end
  
  def min_children
    return @rate_search_container_item.rate_room_type.rate.min_children if @rate_search_container_item.rate_room_type.rate.min_children > 0 and @rate_search_container_item.rate_room_type.rate.restrictions_active
    return 0
  end 
  
  def with_breakfast
    @rate_search_container_item.with_breakfast
  end
  
  def adults
    @rate_search_container_item.adults
  end
  
  def children
    @rate_search_container_item.children
  end
  
  def people
    @rate_search_container_item.adults + @rate_search_container_item.children
  end
  
  def id
    @rate_search_container_item.id
  end
  
  def breakfast_options
    return [[1, "yes"]] if @rate_search_container_item.rate_room_type.rate.breakfast_included  || @rate_search_container_item.with_breakfast
    return [[1, "yes"],[0, "no"]]
  end
  
  def with_breakfast
    return 1 if @rate_search_container_item.with_breakfast
    return 0
  end
  
  #event stuff
  def is_ticket_rate
    # return @rate_search_container_item.rate_room_type.rate.is_ticket_rate?
    return false
  end
  
  def event_names
    return "" if not is_ticket_rate
    return @rate_search_container_item.rate_room_type.rate.assigned_events_names
  end
  
  def event_day
    return @rate_search_container_item.event_day.to_date if not @rate_search_container_item.event_day.nil?
    @rate_search_container_item.rate_search_container.arrival_date.to_date
  end
end
