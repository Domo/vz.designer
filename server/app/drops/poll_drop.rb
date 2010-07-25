class PollDrop < Liquid::Drop

  #param players used for golf stuff
  def initialize(source)
    @poll = source
  end
  
  def question
    @poll.question + "<input type=\"hidden\" name=\"poll[#{@poll.id.to_s}][question]\" value=\"#{@poll.question}\" />"
  end
  
  def answer
    tag = ""
    
   case @poll.answer_type
   when "dropdown"
     tag += "<select name=\"poll[#{@poll.id.to_s}][answer]\">"
     for answer in @poll.answers
       tag += "<option value=\"#{answer}\">#{answer}</option>"
     end
     tag += "</select>"
   when "text"
     tag = "<input type=\"text\" name=\"poll[#{@poll.id.to_s}][answer]\" />"
   when "calendar"
     tag = "<input type=\"text\" name=\"poll[#{@poll.id.to_s}][answer]\" id=\"poll_#{@poll.id.to_s}_answer\" />"
     tag += calendar_button_for "poll_#{@poll.id.to_s}_answer"
   when "memo"
     tag = "<textarea name=\"poll[#{@poll.id.to_s}][answer]\"></textarea>"
   end
   return tag
  end
     
     
  private
  
  #Shows a calendar button for an element.
  def calendar_button_for(element_id, options = {})
    image_id = [element_id, "calendar_image"].join("_")
    image = '<img src="http://assets.visrez.com/roomsandevents/common/v_003/images/calendar.gif" id="' + image_id + '" title="Please click to show calendar" style="cursour: pointer;" />'
    javascript = '<script type="text/javascript">Calendar.setup({inputField :"' + element_id + '", ifFormat:"%d.%m.%Y", button:"' + image_id + '"});</script>'
    return [image, javascript].join("
    ")
  end
     
 end
