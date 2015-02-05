
require 'pp'
require 'logger'


require 'beerdb/models'

puts "BeerDb: #{BeerDb::VERSION}"


DB_CONFIG = {
  adapter: 'sqlite3',
  database: './beer.db'
}

pp DB_CONFIG

ActiveRecord::Base.logger = Logger.new( STDOUT )
ActiveRecord::Base.establish_connection( DB_CONFIG )

BeerDb.create_all

puts 'Done.'
