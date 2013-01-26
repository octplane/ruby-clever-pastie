
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
$: << "."
require 'stdlib'


if ENV['VCAP_SERVICES']

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

  def save_doc(data)
    paste_db.insert(data, :safe => true)
  end

  def cleanup
    paste_db.remove({'expire' => { '$lte' => Time.now.to_i}})
  end

else
  def fetch_doc(id)
    return YAML::load( File.open(File.join(DATA_FOLDER, "#{id}.yaml") ) )
  end
  def save_doc(data)
    File.open(File.join(DATA_FOLDER, "#{data['_id']}.yaml"), "wb") {|file| file.puts(data.to_yaml) }
  end
  def cleanup
    # NOOP
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

get '/c.css' do
  scss :stylesheet
end

post '/paste' do
  @code = params[:content]

  if ! params[:never_expire]
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
    save_doc(data)
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
    @expire = expiry_delay_to_when(@expire)
  end

  haml :index
end

ADMIN_PREFIX = "/admin/" + (ENV['ADMIN_TOKEN'] || '' ) + '/'

get ADMIN_PREFIX+'list' do
  paste_db.find().to_a.join("<br>")+ "<br><br>"
end
get ADMIN_PREFIX + '/env' do
    url = JSON.parse(ENV['VCAP_SERVICES'])['mongodb-1.8'].first["credentials"]["url"]
end
