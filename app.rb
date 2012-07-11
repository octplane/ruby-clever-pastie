
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

def get_counter
  @count ||= begin
    Dir.new(DATA_FOLDER).to_a.length - 2
  end
  @count += 1
end

module Linguist
  # Language bayesian classifier.
  class Classifier
    attr_reader :languages
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
end

get '/' do
  @code = ''
  haml :index
end

post '/' do
  @code = params[:code]
  puts @code
  puts h(@code)
  classifier = Linguist::Classifier.instance
  @scores = classifier.classify(@code).map { |s| [s[0].name, s[1]] }
  count = get_counter
  @name = Rufus::Mnemo.from_integer(count)
  data = { 'content' => @code, 'count' => count, 'scores' => @scores }
  ext = @scores.first.first.downcase
  f = File.open(File.join(DATA_FOLDER, "#{count}"), Fcntl::O_CREAT | Fcntl::O_EXCL | Fcntl::O_WRONLY)
  f.puts data.to_yaml
  f.close
  redirect '/v/'+@name+"."+ext
end

get '/v/:id' do
  mnemo, ext = @params[:id].split(/\./)
  id = Rufus::Mnemo.to_i(mnemo)

  data = YAML::load(File.open(File.join(DATA_FOLDER, id.to_s), 'r'))
  @code = data['content']
  @scores = data['scores']

  haml :index
end
