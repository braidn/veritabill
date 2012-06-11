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

API = Veritable.connect
TABLE = API.table 'veritabill'

disable :logging
set :root, File.dirname(__FILE__) + "/../"

get "/?n?" do
  # render the app page
  # show a table of past estimates and completions
  # show the most recent estimates, with Veritable estimates and a "complete" button
  # show the form to enter a new estimate

  erb :index, :locals => {
    :estimates => estimates,
    :users => ['Yvette', 'Tom', 'Jim', 'Cindy', 'Evelyn'],
    :clients => ['Cyberdyne Systems', 'OCP Inc', 'Mooby\'s Family Restaurants', 'Weyland-Yutani'],
    :days => ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
    :times => ['Morning', 'Lunchtime', 'Afternoon']
  }
end

post "/estimate" do
  register_estimate
  erb :index, :locals => {:estimates => estimates}
end

post "/complete" do
  register_completion
  erb :index, :locals => {:estimates => estimates}
  # post a completion to the database
  # update the Veritable table
  # rerun analysis
end

def estimates(params = nil)
  params.nil? ? Task.last(10) : Task.last(params['n'])
end

def register_estimate(user, client, day, time, estimate)

  Task.create({
    :user => user,
    :day => day,
    :time_of_day => time_of_day,
    :client => client,
    :estimate => estimate
  })
  if most_recent_analysis_created._id == most_recent_analysis_succeeded._id
  else
    n = most_recent_analysis_created._id.split('_')[1].to_i + 1
    most_recent_analysis_created.delete
    TABLE.most_recent_analysis_succeeded(schema, 'veritabill_#{n}')
  end
end

def register_completion(id, true_time)
  Task.update({
    :id => id,
    :true_time => true_time
  })

end

def connect_to_veritable
end

def most_recent_analysis_created
  TABLE.analyses.to_a.max_by {|a| a.created_at}
end

def most_recent_analysis_succeeded
  (TABLE.analyses.to_a.select {|a| a.succeeded?}).max_by {|a| a.created_at}
end
