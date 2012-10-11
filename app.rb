
require 'sinatra'
require 'sinatra/partial'
require 'haml'
require 'cgi'
require 'pp'
require 'json'
require 'fileutils'
require 'yaml'
require 'rufus/mnemo'
require 'fcntl'
require 'mongo'

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

def paste_db
  @paste_db ||= begin
    url = JSON.parse(ENV['VCAP_SERVICES'])['mongodb-1.8'].first["credentials"]["url"]
    cnx = Mongo::Connection.from_uri(url)['paste']
    cnx['pastes']
  end
end
 
def fetch_doc(id)
 paste_db.find_one({"_id" => id })
end

def cleanup
  paste_db.remove({'expire' => { '$lte' => Time.now.to_i}})
end


def expiry_delay_to_ts(expiry_delay)
  case expiry_delay
  when '5 '
  end
end

get '/about' do
	haml :about
end

get '/' do
  @code = ''
  @snippet = "Copie Priv&eacute;e is a new kind of paste website. It will try to auto-detect the language you're pasting."
  haml :index
end

post '/paste' do
  @code = params[:content]

  if not params[:never_expire]
    ts = expiries.find{ |e| e.name == params[:expiry_delay]}
    raise "Unable to find expiry delay = #{params[:expiry_delay]}" if !ts
    expire = ts.expire(Time.now.to_i)
  else
    expire = -1
  end

  data = { 'crypted_content' => @code,  'expire' => expire }
  count = get_counter(0)

  #begin
    @name = Rufus::Mnemo.from_integer(count)
    data['count'] = count
    data['_id'] = @name
    paste_db.insert(data, :safe => true)
#  rescue Exception => e
#    puts e.inspect
#    # next iteration
#    count = get_counter(count)
#    retry
#  end
  '/v/'+@name
end

get '/v/:id' do
  if params[:id].include?('.')
    mnemo, ext = params[:id].split(/\./)
  else
    mnemo = params[:id]
  end
  cleanup
  data = fetch_doc(mnemo)
  if data == nil
    raise Sinatra::NotFound
  end

  if data.has_key?('content')
    @code = data['content']
  elsif data.has_key?('crypted_content')
    @encrypted_content = data['crypted_content']
    @code = nil
  end

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

ADMIN_PREFIX = "/admin/" + ENV['ADMIN_TOKEN'] + '/'

get ADMIN_PREFIX+'list' do
  paste_db.find().to_a.join("<br>")+ "<br><br>"
end
get ADMIN_PREFIX + '/env' do
    url = JSON.parse(ENV['VCAP_SERVICES'])['mongodb-1.8'].first["credentials"]["url"]
end
