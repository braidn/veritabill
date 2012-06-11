# Veritabill 1.0.0, June 11, 2012
# Copyright (c) 2012 Prior Knowledge, Inc.
# Questions? Contact Max Gasner <max@priorknowledge.com>.

require 'sinatra'
require 'data_mapper'
require 'uri'
require 'veritable'

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

API = Veritable.connect
TABLE = API.table 'veritabill'

disable :logging
set :root, File.dirname(__FILE__) + "/../"

get "/" do
  # render the app page
  # show a table of past estimates and completions
  # show the most recent estimates, with Veritable estimates and a "complete" button
  # show the form to enter a new estimate

  erb :index, :locals => {
    :estimates => estimates,
    :user_classes => ['Short', 'Long'],
    :users => ['Yvette', 'Tom', 'Jim', 'Cindy', 'Evelyn'],
    :clients => ['Cyberdyne Systems', 'OCP Inc', 'Mooby\'s Family Restaurants', 'Weyland-Yutani'],
    :days => ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
    :times => ['Morning', 'Lunchtime', 'Afternoon']
  }
end

post "/estimate" do
  # add a new estimate
  register_estimate(params)
  erb :index, :locals => {:estimates => estimates}
end

post "/complete" do
  # complete an existing task, and 
  register_completion
  erb :index, :locals => {:estimates => estimates}
  # post a completion to the database
  # update the Veritable table
  # rerun analysis
end

def estimates(params = nil)
  params.nil? ? Task.last(10) : Task.last(params['n'])
end

def register_estimate(params)
  a = most_recent_analysis_succeeded
  veritable_estimate = a.predict({
    'user' => params[:user],
    'user_class' => params[:user_class],
    'day' => params[:day],
    'time_of_day' => params[:time_of_day],
    'client' => params[:client],
    'user_estimate' => params[:user_estimate],
    'true_time' => nil
    })['true_time']
  Task.create({
    :user => params[:user],
    :user_class => params[:user_class],
    :day => params[:day],
    :time_of_day => params[:time_of_day],
    :client => params[:client],
    :user_estimate => params[:user_estimate],
    :veritable_estimate => veritable_estimate
  })
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

def most_recent_analysis_created
  TABLE.analyses.to_a.max_by {|a| a.created_at}
end

def most_recent_analysis_succeeded
  (TABLE.analyses.to_a.select {|a| a.succeeded?}).max_by {|a| a.created_at}
end
