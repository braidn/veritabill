require 'sinatra'
require 'data_mapper'
require 'uri'

DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/mydb')

class Task
  include DataMapper::Resource
  property :id, Serial
  property :user, String
  property :day, String
  property :time_of_day, String
  property :client, String
  property :true_time, Integer
  property :estimate, Integer
end

DataMapper.auto_upgrade!

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
  Task.last(100)
end

def register_estimate
end

def register_completion
end
