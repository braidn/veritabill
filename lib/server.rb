require 'sinatra'
require 'data_mapper'
require 'uri'
require 'veritable'

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

api = Veritable.connect
table = api.table 'veritabill'

disable :logging
set :root, File.dirname(__FILE__) + "/../"

get "/" do
  ee = estimates
  ee.each {|e|
    e['predicted'] = most_recent_analysis.predict
  }
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
  if last_analysis_created._id == last_analysis_succeeded._id
  else
    n = last_analysis_created._id.split('_')[1].to_i + 1
    last_analysis_created.delete
    table.create_analysis(schema, 'veritabill_#{n}')
  end
end

def estimates(params = nil)
  params.nil? Task.last(10) 
end

def register_estimate
end

def register_completion
end

def connect_to_veritable
end

def last_analysis_created
  table.analyses.to_a.max_by {|a| a.created_at}
end

def last_analysis_succeeded
  (table.analyses.to_a.select {|a| a.succeeded?}).max_by {|a| a.created_at}
end
