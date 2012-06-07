require 'veritable'
require 'data_mapper'
require 'seed'

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

DataMapper.auto_migrate!

schema = Veritable::Schema.new({
  'user' => {'type' => 'categorical'},
  'day' => {'type' => 'categorical'},
  'time_of_day' => {'type' => 'categorical'},
  'client' => {'type' => 'categorical'},
  'true_time' => {'type' => 'count'},
  'estimate' => {'type' => 'count'}
})
records = SEED_DATA
clean_data(records, schema)

api = Veritable.connect
t = Veritable.create_table('veritabill', {'force' => true})

records.each {|r|
  Task.create({
    :user => r['user'],
    :day => r['day'],
    :time_of_day => r['time_of_day'],
    :client => r['client'],
    :true_time => r['true_time'],
    :estimate => r['estimate']
  })
  t.upload_row(r)
}

t.create_analysis(schema, 'veritabill_1')
t.wait
