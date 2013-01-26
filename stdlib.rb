DATA_FOLDER = File.join(File.dirname(__FILE__), 'data')
FileUtils.mkdir_p(DATA_FOLDER)

def get_counter(iteration)
  if iteration == 0
    rand(100_000)
  else
    iteration + 1
  end
end

# This is a selectable item in a web interface
# than can also be instanciated later to compute
# date of expiry
class TimeSpan
  attr_reader :name
  def initialize(name, duration, selected = false)
    @name = name
    # In seconds
    @duration = duration
    @selected = selected
  end
  def html_properties
    if @selected
      {:selected => 'selected'}
    else
      {}
    end
  end
  def expire(t)
    return t+@duration
  end
end

helpers do
  def h(html)
    CGI.escapeHTML html
  end
  def expiries
    [ TimeSpan.new('5 minutes',   5*60),
      TimeSpan.new('30 minutes', 30*60),
      TimeSpan.new('1 hour',     60*60),
      TimeSpan.new('1 day',   24*60*60, true),
      TimeSpan.new('1 week',   7*86400),
      TimeSpan.new('1 year', 365*86400)
    ]
  end
end

def expiry_delay_to_when(expiry_delay)
  delta =  expiry_delay - Time.now.to_i
  if delta > 86400
    ndays = delta / 86400
    return "#{ndays} days"
  end
  if delta > 3600
    nhours = delta / 3600
    return "#{nhours} hours"
  end
  "#{delta/60} minutes"
end