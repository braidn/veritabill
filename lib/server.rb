require 'sinatra'
require 'active_record'
require 'uri'

db = URI.parse(ENV['DATABASE_URL'] || 'postgres://localhost/mydb')

ActiveRecord::Base.establish_connection(
  :adapter  => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
  :host     => db.host,
  :port     => db.port,
  :username => db.user,
  :password => db.password,
  :database => db.path[1..-1],
  :encoding => 'utf8'
)

disable :logging
set :root, File.dirname(__FILE__) + "/../"

get "/" do
  # render the app page
  # show a table of past estimates and completions
  # show the most recent estimates, with Veritable estimates and a "complete" button
  # show the form to enter a new estimate
  erb :index, :locals => {:estimates => estimates}
end

post "/estimate" do
  register_estimate
  erb :index, :locals => {:estimates => estimates}
  # post a new estimate to the database
  # make a prediction
  # show the prediction
end

post "/complete" do
  register_completion
  erb :index, :locals => {:estimates => estimates}
  # post a completion to the database
  # update the Veritable table
  # rerun analysis
end

def estimates
end

def register_estimate
end

def register_completion
end
