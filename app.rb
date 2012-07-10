
require 'sinatra'
require 'sinatra/partial'
require 'haml'
require 'linguist'
require 'cgi'
require 'pp'

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
  @scores = classifier.classify(@code)
  pp @scores

  haml :index
end

# Dummy class to make Linguist happy
class LanguageContainer
 attr_accessor :name
end

get '/learn' do
  @code = ''
  @language = ''
  haml :learn
end

get "/debug" do
end


c = Linguist::Classifier

module Linguist
  # Language bayesian classifier.
  class Classifier
    attr_reader :tokens
  end
end

require 'fileutils'
require 'pp'


post '/learn' do
  @code = params[:code]
  @language = params[:lang]
  lc = LanguageContainer.new
  lc.name = @language
  classifier = Linguist::Classifier.instance
  folder = File.expand_path("../data/#{Time.now.to_i}", __FILE__)
  FileUtils.mkdir_p(folder)
  puts "Saving in #{folder}"
  File.open(File.join(folder, 'original.yml'), 'w') { |origin|
    classifier.to_yaml(origin)
  }
  File.open(File.join(folder, 'source'), 'w') { |source|
	source.puts "Language: #{@languages}"
	source.puts "Content: #{@code}"
    source.puts "Ip: #{ENV['REMOTE_ADDR']}"
  }
  Linguist::Classifier.new.train(lc, @code)
  File.open(File.join(folder, 'modified.yml'), 'w') { |origin|
    classifier.to_yaml(origin)
  }

end
