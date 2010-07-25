require 'poll_drop'

class EventAvailabilityDrop < Liquid::Drop

  #param players used for golf stuff
  def initialize(source, time=nil, players=0)
    @source = source
    @time = time
    @players = players
  end
  
  def date
    @source.start_date.to_date
  end

  def time_frame
    @time
  end

  def booking_fee
    @source.booking_fee
  end

  def name
    @source.name
  end

  def description
    @source.description
  end

  def short_description
    @source.short_description
  end
  
  def terms_and_conditions
    @source.event.terms_and_conditions
  end
  
  def players
    @players
  end

  def has_times
    golf_times if @times.nil?
    @times.length > 0
  end

  #used for golf things  
  def golf_times
    @times = @source.event_availability_times.find(:all, :include => [:assigned_tickets]).collect{|x| GolfTimeDrop.new(x, @players) }
    #@times = @source.event_availability_times.collect{|x| GolfTimeDrop.new(x, @players) }
    
    if @time == "morning"
      s = "00:00:00"    
      e = "12:00:00"
    elsif @time == "afternoon"
      s = "12:00:00"    
      e = "17:00:00"
    elsif @time == "evening"
      s = "17:00:00"    
      e = "23:59:00" 
    end
    
    if Date.today == date
      @times = @times.collect{|x| x if x.starttime.strftime("%H:%M:00") >= Time.now.strftime("%H:%M:00")}.compact
    end
    
    @times = @times.collect{|x| x if x.active }.compact
    
    #sort day times
    return @times if @time == "any"
    @times = @times.collect{|x| x if x.time >= s and x.time <= e}.compact
    
    return @times
  end
  
  def questions
    questions = []
    for poll in @source.polls
      questions << PollDrop.new(poll)
    end
    
    return questions
  end
  
  def has_questions
    (not @source.polls.empty?)
  end
  
end
