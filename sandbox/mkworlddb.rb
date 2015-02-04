
require 'pp'
require 'logger'


require 'worlddb/models'

puts "WorldDb: #{WorldDb::VERSION}"

DB_CONFIG = {
  adapter: 'sqlite3',
  database: './world.db'
}

pp DB_CONFIG

ActiveRecord::Base.logger = Logger.new( STDOUT )
ActiveRecord::Base.establish_connection( DB_CONFIG )

WorldDb.create_all

puts 'Done.'
