// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults



function select_choose(select, prefix, cls) {
  
  if(cls != null){
    others = $$(cls);
    others.each(function(e){
      e.hide();
    });
  }
  
  new Effect.Appear(prefix + select.value);
	return false;
};

var ME = Class.create();
ME.toggle = function(element){
	new Effect.toggle(element,'slide', { duration: 0.3 });
	return false
}

var SelectHelper = Class.create({

  initialize: function() {
    alert('fads');
  }
  /*
  select_choose: function(select, prefix, class){
    alert('dsaf');
    //if(class != null){
    //  others = $$(class);
    //  others.each(function(e){
    //    e.hide();
    //  });
    //}
    alert('222');
    //alert(select.value);
    //new Effect.Appear(prefix + select.value);
  	return false;
  }*/

});


var AvailabilityExceptDates = Class.create();
AvailabilityExceptDates.prototype = {
	
	pf: null,
	nextId: 1,
	
	initialize: function(parent_field) {
		this.pf = $(parent_field);
		this.nextId = $$('#' + parent_field + ' .pea_date').length + 1;
	},
	
	addDateField: function(value) {
	 
	 if (!value) value = ''
	 	
	 text  = '<div class="pea_date" id="pae_date_' + this.nextId + '">'
	 text += '<input class="datefield" id="product_availability_except_dates_' + this.nextId + '" name="product_availability[except_dates][]" type="text" value="' + value + '" />';
	 text += '<img alt="Calendar" id="product_availability_except_dates_' + this.nextId + '_calendar" onmouseout="this.style.background=\'\'" onmouseover="this.style.background=\'red\';" src="/images/icons/silk/calendar.png" style="vertical-align: middle; cursor: pointer; border: 1px solid red;" title="Select date" />';
   text += '<a href="#" onclick="Element.remove(\'pae_date_' + this.nextId + '\'); return false;"><img src="/images/icons/silk/delete.png" alt="Remove date" /></a>'
	 text += '<script type="text/javascript">Calendar.setup({inputField :\'product_availability_except_dates_' + this.nextId + '\', ifFormat:\'%d.%m.%Y\', button: \'product_availability_except_dates_' + this.nextId + '_calendar\'});</script>';
	 text += '</div>'
	 
	 new Insertion.Bottom(this.pf, text)
	 
	}
}

var CustomerContacts = Class.create();
CustomerContacts.prototype = {
	
	pf: null,
	nextId: 1,
	
	initialize: function(parent_field) {
		this.pf = $(parent_field);
		this.nextId = $$('#' + parent_field + ' .ccontact').length + 1;
	},
	
	addContactForm: function(value) {
	 
	 if (!value) value = ''
	 
	 new Ajax.Request("/customers/ajax_one_next_contact_form", {
		 	method: 'post',
			parameters: { id: this.nextId },
			onSuccess: function(response) {
				text  = '<div class="ccontact" id="ccontact_' + this.nextId + '">'
	 			text += response.responseText;
	 			text += '</div>'
	 
	 			new Insertion.Bottom(this.pf, text)
			}.bindAsEventListener(this),
			onFailure: function(error) {
				alert('Ajax Error: ' + error.toString());
			}
	 });	
	 
	} //addContactForm
}

var EventQuantity = Class.create();
EventQuantity.prototype = {
	
	select_element: null,
	update_element: null,
	
	initialize: function() {},
	
	loadNewQuantity: function(select_element, update_element) {
	 
	  this.select_element = $(select_element);
	  this.update_element = $(update_element);
    new Ajax.Updater(update_element, "/web_booking/ajax_get_quantity_options_for_event", {
     	method: 'post',
    	parameters: { id: this.select_element.options[this.select_element.selectedIndex].value },
    	onLoading: function() {
    	  this.update_element.disabled = 1;
    	}.bindAsEventListener(this),
    	onComplete: function() {
    	  this.update_element.disabled = 0;
    	}.bindAsEventListener(this),
    	onFailure: function(error) {
    		alert('Ajax Error: ' + error.toString());
    	}
    });	
	 
	} //loadNewQuantity
}
	
	
var ResizingTextArea = Class.create();
	
ResizingTextArea.prototype = {
	defaultRows: 1,
	
	initialize: function(field)
	{
	    this.defaultRows = Math.max(field.rows, 1);
	    this.resizeNeeded = this.resizeNeeded.bindAsEventListener(this);
	    Event.observe(field, "click", this.resizeNeeded);
	    Event.observe(field, "keyup", this.resizeNeeded);
	},
	
	resizeNeeded: function(event)
	{
	    var t = Event.element(event);
	    var lines = t.value.split('\n');
	    var newRows = lines.length + 1;
	    var oldRows = t.rows;
	    for (var i = 0; i <lines.length; i++)
	    {
	        var line = lines[i];
	        if (line.length>= t.cols) newRows += Math.floor(line.length / t.cols);
	    }
	    if (newRows> t.rows) t.rows = newRows;
	    if (newRows <t.rows) t.rows = Math.max(this.defaultRows, newRows);
	}
}

function switchArrowsSlider(slider){
  if($(slider).className == 'arrows_down'){
    Element.classNames($(slider)).set('arrows_up');
  }else{
    Element.classNames($(slider)).set('arrows_down');
  }
  
}

Ajax.Responders.register({
  onCreate: function(){
    Element.show('ajax_call_indicator');
  }, 
  onComplete: function(){
    Element.hide('ajax_call_indicator');
  }
});
	
function card_cvv(select_card, text_cvv) {
  select = $(select_card)
  if(select.selectedIndex == 1){
    $(text_cvv).hide()  
  } else {
    $(text_cvv).show();  
  }
}

var CalendarHelper = Class.create();
CalendarHelper.prototype = {
  
  initialize: function(year, month, event_id, quantity) {
    new Ajax.Updater({ 
      success:'event_calendar_wrapper'
    }, '/web_booking/calendar_ajax', 
    {
      parameters: { 
        month: month,
        year: year,
        event_id: event_id,
        quantity: quantity 
      },
      asynchronous: true, 
      evalScripts: true, 
      onComplete: function(request) { 
        $("overlay-indicator").toggle();
      }, 
      onLoading: function(request) { 
        $("overlay-indicator").toggle();
      }
    }); 
  
  }
  
}

  function showAvailabilityTime(element) {
    elements = document.getElementsByClassName("time_element");
    for (i=0;i<elements.length;i++) {
      elements[i].hide();
    }
    options = element.options;
    id = options[element.selectedIndex].value;
    $("time_"+id).show();
  }

  function updatePrice(element) {
    Element.show("totalcost");
    elements = document.getElementsByClassName(element.id + "_ticketselector");
    total = 0.0;
    for (i=0;i<elements.length;i++) {
      price = elements[i].title;
      element = elements[i];
      options = element.options;
      counter = options[element.selectedIndex].value;
      total = total + counter * element.title;
    }
    $(element.id + "_price").innerHTML =  " &euro;" + round(total,2);
  }
  function round(x, n) {
    if (n < 1 || n > 14) return false;
    var e = Math.pow(10, n);
    var k = (Math.round(x * e) / e).toString();
    if (k.indexOf(".") == -1) k += ".";
    k += e.toString().substring(1);
    return k.substring(0, k.indexOf(".") + n+1);
  }

	


