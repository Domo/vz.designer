var CalendarHelper = Class.create();
CalendarHelper.prototype = {
  
  initialize: function(year, month, event_id, quantity) {
    new Ajax.Updater({ 
      success:'event_calendar_wrapper'
    }, '/ticket_booking/calendar_ajax', 
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