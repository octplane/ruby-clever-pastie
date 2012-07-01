
require 'sinatra'
require 'haml'
require 'linguist'

module Linguist
  # Language bayesian classifier.
  class Classifier
    attr_reader :languages
  end
end
  

get '/' do
  @code = ''
  haml :index
end

post '/paste' do
  @code = params[:code]
  classifier = Linguist::Classifier.instance
  @scores = classifier.classify(@code)

  haml :index
end

