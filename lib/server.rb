# Veritabill 1.0.0, June 11, 2012
# Copyright (c) 2012 Prior Knowledge, Inc.
# Questions? Contact Max Gasner <max@priorknowledge.com>.

require 'sinatra'
require 'data_mapper'
require 'uri'
require 'veritable'

# database and model setup
DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/mydb')

class Task
  include DataMapper::Resource
  property :id, Serial
  property :user_class, String
  property :user, String
  property :day, String
  property :time_of_day, String
  property :client, String
  property :true_time, Integer
  property :user_estimate, Integer
  property :veritable_estimate, Float
end

DataMapper.auto_upgrade!

# connect to Veritable
API = Veritable.connect
TABLE = API.table 'veritabill'

def most_recent_analysis_created
  TABLE.analyses.to_a.max_by {|a| a.created_at}
end

def most_recent_analysis_succeeded
  (TABLE.analyses.to_a.select {|a| a.succeeded?}).max_by {|a| a.created_at}
end

# set up Sinatra app
disable :logging
set :root, File.dirname(__FILE__) + "/../"

# main app route: renders a table of past tasks
get "/" do
  erb :index, :locals => {
    :estimates => estimates,
    :user_classes => ['Short', 'Long'],
    :users => ['Yvette', 'Tom', 'Jim', 'Cindy', 'Evelyn'],
    :clients => ['Cyberdyne Systems', 'OCP Inc', 'Mooby\'s Family Restaurants', 'Weyland-Yutani'],
    :days => ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
    :times => ['Morning', 'Lunchtime', 'Afternoon']
  }
end

# adds a new estimate
post "/estimate" do
  register_estimate(params)
  redirect "/"
end

post "/complete" do
  # complete an existing task, and 
  # post a completion to the database
  # update the Veritable table
  # rerun analysis
  register_completion
  redirect "/"
end

def estimates(params = nil)
  params.nil? ? Task.last(10) : Task.last(params['n'])
end

# does some basic form validation, uses the most recent Veritable analysis completed to make a prediction for the time the task will actually take, and adds the new task and estimates to the database
def register_estimate(params)
  if params.all? {|x| x} and params[:user_estimate].is_a? Integer
    a = most_recent_analysis_succeeded
    veritable_estimate = a.predict(stringify_hash_keys(params).update(
      'true_time' => nil))['true_time']
    Task.create(params)
  end
end

def register_completion(id, true_time)
  t = Task.get(id)
  Task.update({
    :true_time => true_time
  })
  n = most_recent_analysis_created._id.split('_')[1].to_i + 1
  if most_recent_analysis_created._id != most_recent_analysis_succeeded._id
    most_recent_analysis_created.delete
  end
  TABLE.create_analysis(schema, 'veritabill_#{n}')
end


def stringify_hash_keys(h)
  j = {}
  h.each {|k, v| j[k.to_s] = v}
  j
end
