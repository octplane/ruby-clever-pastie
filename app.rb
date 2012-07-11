
require 'sinatra'
require 'sinatra/partial'
require 'haml'
require 'linguist'
require 'cgi'
require 'pp'
require 'json'

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
