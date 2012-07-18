
require 'sinatra'
require 'sinatra/partial'
require 'haml'
require 'linguist'
require 'cgi'
require 'pp'
require 'json'
require 'fileutils'
require 'yaml'
require 'rufus/mnemo'
require 'fcntl'

DATA_FOLDER = File.join(File.dirname(__FILE__), 'data')
FileUtils.mkdir_p(DATA_FOLDER)

def get_counter(iteration)
  if iteration == 0
    rand(100_000)
  else
    iteration + 1
  end
end

module Linguist
  # Language bayesian classifier.
  class Classifier
    attr_reader :languages
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
  def color
    ['btn-primary', 'btn-success', 'btn-info']
  end
  def prefix
    "this is "
  end
  def expiries
    [ TimeSpan.new('5 Minutes',   5*60),
      TimeSpan.new('30 Minutes', 30*60),
      TimeSpan.new('1 hour',     60*60),
      TimeSpan.new('1 day',   24*60*60, true),
      TimeSpan.new('1 week',   7*86400),
      TimeSpan.new('1 year', 365*86400)
    ]
  end
end

def expiry_delay_to_ts(expiry_delay)
  case expiry_delay
  when '5 '
  end
end
get '/' do
  @code = ''
  @snippet = "Copie Priv&eacute;e is a new kind of paste website. It will try to auto-detect the language you're pasting."
  haml :index
end

post '/' do
  @code = params[:code]
  redirect '/' if @code == ""

  if not params[:never_expire]
    ts = expiries.find{ |e| e.name == params[:expiry_delay]}
    raise "Unable to find expiry delay = #{params[:expiry_delay]}" if !ts
    expire = ts.expire(Time.now.to_i)
  else
    expire = -1
  end

  classifier = Linguist::Classifier.instance
  @scores = classifier.classify(@code).map { |s| [s[0].name, s[1]] }
  data = { 'content' => @code, 'scores' => @scores, 'expire' => expire }
  ext = @scores.first.first.downcase

  count = get_counter(0)

  begin
    @name = Rufus::Mnemo.from_integer(count)
    f = File.open(File.join(DATA_FOLDER, "#{count}"), Fcntl::O_CREAT | Fcntl::O_EXCL | Fcntl::O_WRONLY)
  rescue Errno::EEXIST
    # next iteration
    count = get_counter(count)
    retry
  end
  data['count'] = count
  f.puts data.to_yaml
  f.close
  redirect '/v/'+@name
end

get '/v/:id' do
  if params[:id].include?('.')
    mnemo, ext = params[:id].split(/\./)
  else
    mnemo =params[:id]
  end
  
  id = Rufus::Mnemo.to_i(mnemo)

  data = YAML::load(File.open(File.join(DATA_FOLDER, id.to_s), 'r'))
  @code = data['content']
  @scores = data['scores']
  @expire = data['expire']
  if @expire == -1
    @never = true
    @expire = ""
  else
    @never = false
    @expire = Time.at(@expire)
  end

  haml :index
end
