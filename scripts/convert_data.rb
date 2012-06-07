require 'veritable'

DATASOURCE = "seed_data.csv"

seed = File.open("seed.rb", mode = "w") {|f|
  f.puts("seed_data = #{Veritable::Util.read_csv(DATASOURCE)}")
}
