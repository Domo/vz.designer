// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// Try to be compatible with other browsers
// Only use firebug logging when available
if (typeof console == 'undefined') {
    console = new Object;
    console.trace = function() {};
    console.log = function() {};
    console.debug = function() {};
    console.info = function() {};
    console.warn = function() {};
    console.error = function() {};
    console.time = function() {};
    console.timeEnd = function() {};
    console.count = function() {};
}


function toggle_room(id) {
	Element.toggle(id); 
	Element.toggleClassName( "room_" + id, 'active'); 
	return false;
}

function disableButton(element) {
    $(element).disabled = true;
    $(element).addClassName('disabled');
}

function card_cvv(select_card, creditcard_verification_value) {
  select = $(select_card)
  if(select.selectedIndex == 1){
    $("cvv_text").hide()  
  } else {
    $("cvv_text").show();  
  }
}

var ME = Class.create();
ME.toggle = function(element){
	new Effect.toggle(element,'slide', { duration: 0.3 });
	return false;
}

var ReservationsManager = Class.create();
ReservationsManager.prototype = {
  
  room_type_settings: $H({}),
  conditions_settings: $H({}),
  basic_template: null,
  adults_option_tags_template: null,
  children_option_tags_template: null,
  roomTypePrice: 0,
  totalPrice: 0,
  
  initialize: function(_room_type_settings, _conditions_settings,
    _basic_template, _adults_option_tags_template, _children_option_tags_template,
    _template_min_number_of_rooms_error_message, _template_min_number_of_people_error_message, 
    _template_max_number_of_people_error_message) {
    
    this.room_type_settings = $H(_room_type_settings);
    this.conditions_settings = $H(_conditions_settings);
    this.basic_template = new Template(_basic_template);
    this.adults_option_tags_template = new Template(_adults_option_tags_template);
    this.children_option_tags_template = new Template(_children_option_tags_template);
    this.template_min_number_of_rooms_error_message = new Template(_template_min_number_of_rooms_error_message);
    this.template_min_number_of_people_error_message = new Template(_template_min_number_of_people_error_message);
    this.template_max_number_of_people_error_message = new Template(_template_max_number_of_people_error_message);
  },
  
  numberOfRoomsChanged: function(_id, _container_name, table_id, select_tag) {
    
    var room_definitions = $$('#' + table_id + ' tr.room_definition');
    var actual_count = room_definitions.length;
    var requested_count = $(select_tag).options[$(select_tag).selectedIndex].value;
    
    diff = requested_count - actual_count;
    if (diff == 0) { return; }
    if (diff > 0) {
      min_adults = this.room_type_settings.get(_id)['min_adults'] || 0;
      adults = this.room_type_settings.get(_id)['adults'] || 0;
      children = this.room_type_settings.get(_id)['children'] || 0;
      max_children = this.room_type_settings.get(_id)['max_children'] || 0;
      
      text = ''
      text = template_text = this.defineRooms(_id, _container_name, min_adults, adults, children, max_children, diff, actual_count, table_id, select_tag);
      
      new Insertion.Bottom($$('#' + table_id + ' tbody')[0], text);
      
    } else {
      for(i=1;i<=Math.abs(diff);i++) {
        room_definitions[actual_count - i].remove();
      }
    }
    
    this.recalculateRoomTypePrice(_id, _container_name);
    var errors = $A([]);
    errors = this.validateMinNumberOfRooms(requested_count, this.conditions_settings.get(_id)['min_rooms']);
    errors = errors.concat(this.validateMinNumberOfPeople(_id, _container_name));
    this.publishConditionsErrors(_id, errors, requested_count);
  },
  
  pluralizeLabel: function(_id, _count, _singular) {
    _id = $(_id);
    _id.innerHTML = pluralize_without_count({count:_count,singular:_singular});
  },
  
  numberOfPeopleChanged: function(_id, _container_name, _table_id, _select_tag, _i, _singular) {
    var errors = $A([]);
    var requested_count = $(_select_tag).options[$(_select_tag).selectedIndex].value;
    id = _container_name+'_'+_id+'_'+_singular+'_'+_i.toString();
    count = $(id).options[$(id).selectedIndex].value;
    //this.pluralizeLabel(id+'_label', count, _singular);
    
    this.recalculateRoomTypePrice(_id, _container_name);
    
    errors = this.validateMinNumberOfRooms(requested_count, this.conditions_settings.get(_id)['min_rooms']);
    errors = errors.concat(this.validateMinNumberOfPeople(_id, _container_name));
    this.publishConditionsErrors(_id, errors, requested_count);
  },
  
  publishConditionsErrors: function(_id, _errors, _rooms) {
    var conditionsContainer = $('conditions_' + _id.toString());
    
    var html = '';
    if (_errors.length > 0) {
      html = _errors.inject('', function(str, error) {
        str += '<li>' + error + '</li>';
        return str;
      });
    } else {
      html = '<div style="color:#0d0;">You have selected ' + pluralize({count: _rooms, singular: "room"}) + '.</div>';
    }
    
    if (conditionsContainer != null) {
      conditionsContainer.innerHTML = html;
    }
  },
  
  validateMinNumberOfRooms: function(_rooms_selected, _min_rooms_required) {
    if (_min_rooms_required == NaN || _min_rooms_required == null) _min_rooms_required = 0;
    if (_rooms_selected < _min_rooms_required) {
      return $A([this.template_min_number_of_rooms_error_message.evaluate({min_rooms_required: pluralize({count: _min_rooms_required, singular: 'room'})})])
    }
    return $A([]);
  },
  
  validateMinNumberOfPeople: function(_id, _container_name) {
    _min_people_required = this.conditions_settings.get(_id)['min_people'];
    _max_people_required = this.conditions_settings.get(_id)['max_people'];
    if (_min_people_required == NaN || _min_people_required == null) _min_people_required = 0;
    if (_max_people_required == NaN || _max_people_required == null) _max_people_required = 0;
    
    var adults = $A([]); var children = $A([]);
    adults_nodes = $$('select.' + _container_name + '_' + _id + '_adults');
    adults = adults_nodes.inject([], function(acc, adult_select) {
      acc.push(parseInt(adult_select.options[adult_select.selectedIndex].value));
      return acc;
    });
    children_nodes = $$('select.' + _container_name + '_' + _id + '_children');
    children = children_nodes.inject([], function(acc, children_select) {
      acc.push(parseInt(children_select.options[children_select.selectedIndex].value));
      return acc;
    });
    
    var errors = $A([]);
    for(i=0;i<adults.length;i++) {
      if ((adults[i] + children[i]) < _min_people_required && _min_people_required != 0) {
        errors.push(this.template_min_number_of_people_error_message.evaluate({i: i + 1, min_people_required: pluralize({count:_min_people_required,singular:'person'})}));
      }
      if ((adults[i] + children[i]) > _max_people_required && _max_people_required != 0) {
        errors.push(this.template_max_number_of_people_error_message.evaluate({i: i + 1, max_people_required: pluralize({count:max_people_required,singular:'person'})}));
      }
    }
    return errors;
  },
  
    
  defineRooms: function(_id, _container_name, _min_adults, _adults, _children, _max_children, _rooms, _from_number, _table_id, _select_tag) {
    var data = $H({
      adults_option_tags: this.renderAdultsOptions(_min_adults, _adults),
      children_option_tags: this.renderChildrenOptions(_children, _max_children),
      id: _id,
      container_name: _container_name,
      i: 0,
      table_id: _table_id,
      select_tag: _select_tag
    });
    
    text = ''
    for (i=0;i<diff;i++) {
      data.set('i', _from_number + i + 1);
      text += this.basic_template.evaluate(data);
    }
    return text;
  },
  
  renderAdultsOptions: function(min_adults, adults) {
    adults_options = '';
    for(j=min_adults;j<=adults;j++) {
      adults_options += this.adults_option_tags_template.evaluate({i: j});
    }
    return adults_options;
  },
  
  renderChildrenOptions: function(children, max_children) {
    children_options = '';
    for(j=children;j<=max_children;j++) {
      children_options += this.children_option_tags_template.evaluate({i: j});
    }
    return children_options;
  },
  
  recalculateTotalPrice: function() {
    this.totalPrice = this.recalculateTotalStandardRoomTypePrice() + this.recalculateTotalRatePlanRoomTypePrice();
    //$('total_price').innerHTML = this.totalPrice.toString();
  },
  
  recalculateTotalStandardRoomTypePrice: function() {
    
    var prices = $$('span.room_type_price');
    var totalPrice = 0;
    totalPrice = prices.inject(0, function(totalPrice, price){
      price_int = parseInt(price.innerHTML);
      price_int = (price_int == NaN) ? 0 : price_int;
      totalPrice += price_int;
      return totalPrice;
    }.bind(this));
    
    return totalPrice;
  },

  recalculateTotalRatePlanRoomTypePrice: function() {
    
    var prices = $$('span.rate_plan_room_type_price');
    var totalPrice = 0;
    totalPrice = prices.inject(0, function(totalPrice, price){
      price_int = parseInt(price.innerHTML);
      price_int = (price_int == NaN) ? 0 : price_int;
      totalPrice += price_int;
      return totalPrice;
    }.bind(this));
    
    return totalPrice;
  },

  recalculateRoomTypePrice: function(result_id, _container_name) {
    var adults = this.getAdultsNumbers(result_id, _container_name);
    var children = this.getChildrenNumbers(result_id, _container_name);
    var price = this.getRoomTypePrice(result_id, adults, children);
    var priceTag = $(_container_name + '_' + result_id + '_price');
    if (priceTag) {
      priceTag.innerHTML = price.toString();
    }
    this.recalculateTotalPrice();
  },
  
  getAdultsNumbers: function(result_id, _container_name) {
    var adultsSelects = $$('select.' + _container_name + '_' + result_id + '_adults');
    var numbers = $A();
    numbers= adultsSelects.inject([], function(arr, aSelect) {
      arr.push(this.getNumberOfAdults(aSelect));
      return arr;
    }.bind(this));
    return numbers;
  },
  
  getNumberOfAdults: function(select) {
    var adults = parseInt(select.options[select.selectedIndex].value);
    return ((adults == NaN) ? 0 : adults);
  },
  
  getChildrenNumbers: function(result_id, _container_name) {
    var childrenSelects = $$('select.' + _container_name + '_' + result_id + '_children');
    var numbers = $A();
    numbers = childrenSelects.inject([], function(arr, cSelect) {
      arr.push(this.getNumberOfChildren(cSelect));
      return arr;
    }.bind(this));
    return numbers;
  },
  
  getNumberOfChildren: function(select) {
    var children = parseInt(select.options[select.selectedIndex].value);
    return ((children == NaN) ? 0 : children);
  },
  
  getRoomTypePrice: function(result_id, adults, children) {
    
    this.roomTypePrice = 0;
    this.roomTypePrice = this.room_type_settings.get(result_id)['sell_rate'] * adults.size();
    
    this.roomTypePrice += adults.inject(0, function(acc, number_of_adults) {
      acc += this.getExtraPriceForAdults(result_id, number_of_adults);
      return acc;
    }.bind(this));
    
    this.roomTypePrice += children.inject(0, function(acc, number_of_children) {
      acc += this.getExtraPriceForChildren(result_id, number_of_children);
      return acc;
    }.bind(this));
    
    return this.roomTypePrice;
  },
  
  getExtraPriceForAdults: function(result_id, number_of_adults) {
    var min_adults = this.room_type_settings.get(result_id)['min_adults'];
    var extra_adult_price = this.room_type_settings.get(result_id)['extra_adult'];
    var diff = min_adults - number_of_adults;
    if (diff < 0) {
      return Math.abs(diff) * extra_adult_price;
    }
    return 0;
  },
  
  getExtraPriceForChildren: function(result_id, number_of_children) {
    var children = this.room_type_settings.get(result_id)['children'];
    var extra_child_price = this.room_type_settings.get(result_id)['extra_child'];
    var diff = children - number_of_children;
    if (diff < 0) {
      return Math.abs(diff) * extra_child_price;
    }
    return 0;
  },
  
  checkForCheckout: function() {
    var rooms = $$('.room_definition');
    if (rooms.size() > 0) {
      return true;
    }
    alert('Sorry, you can\'t checkout. No room selected.');
    return false;
  }
}

  function updatePrice() {
    elements = document.getElementsByClassName("ticketselector");
    total = 0.0;
    for (i=0;i<elements.length;i++) {
      price = elements[i].title;
      element = elements[i];
      options = element.options;
      counter = options[element.selectedIndex].value;
      total = total + counter * element.title;
    }
    $("price").innerHTML =  " &euro;" + round(total,2);
  }
  function round(x, n) {
    if (n < 1 || n > 14) return false;
    var e = Math.pow(10, n);
    var k = (Math.round(x * e) / e).toString();
    if (k.indexOf(".") == -1) k += ".";
    k += e.toString().substring(1);
    return k.substring(0, k.indexOf(".") + n+1);
  }
