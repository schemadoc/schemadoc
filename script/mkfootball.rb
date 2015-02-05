
require 'pp'
require 'logger'


require 'sportdb/models'

puts "SportDb: #{SportDb::VERSION}"


DB_CONFIG = {
  adapter: 'sqlite3',
  database: './football.db'
}

pp DB_CONFIG

ActiveRecord::Base.logger = Logger.new( STDOUT )
ActiveRecord::Base.establish_connection( DB_CONFIG )

SportDb.create_all

puts 'Done.'
