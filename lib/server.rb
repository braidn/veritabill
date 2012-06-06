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
  File.readlines("public/index.html")
end

post "/estimate" do

end

post "/finish" do
  
end
