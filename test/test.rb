
###
# generate
#  json
#   for schema doc
#  (see simple datasets package schema from okfn ???)


require 'active_record'

require 'pp'
require 'json'
require 'yaml'


$DB_CONFIG = {
  adapter:  'sqlite3',
  database: './worldcup2014.db'
}

$CONFIG = YAML.load_file( './schemadoc.yml' )

pp $CONFIG



def find_schema_for_table( name )
  
  $CONFIG.each do |k,h|
    tables = h['tables'] || []
    if tables.include?( name )
      return k
    end
  end

  ## no entry found; assume default schema (e.g. first schema listed in config)
  $CONFIG.keys.first
end





class AbstractModel < ActiveRecord::Base
  self.abstract_class = true   # no table; class just used for getting db connection

  def self.connection_for( key )
    establish_connection( key )
    connection
  end
end  # class AbstractModel


con = AbstractModel.connection_for( $DB_CONFIG )



con.tables.sort.map do |name|
  puts "#{name} : #{name.class.name}"
end

con.tables.sort.each do |name|
  puts "#{name}"
  puts "--------------"

  con.columns( name ).each do |col|
    puts "  #{col.name} #{col.sql_type}, #{col.default}, #{col.null} : #{col.class.name}"
  end
  puts ''
end

####
# build schema hash


schemas = {}

con.tables.sort.each do |name|

  t = { name: name,
        columns: []
  }
  con.columns( name ).each do |col|
    t[:columns] << {
       name:    col.name,
       type:    col.sql_type,
       default: col.default,
       null:    col.null
    }
  end

  schema_name = find_schema_for_table(name)
  puts "add '#{name}' to schema '#{schema_name}'"

  schema = schemas[schema_name]
  if schema.nil?
    ## use schema_name from config (do NOT use key - might be different)
    schema = { name: schema_name, tables: [] }
    schemas[schema_name] = schema
  end
  schema[:tables] << t
end


data = { schemas: [] }
schemas.each do |k,v|
  data[:schemas] << v   ## turn schemas into an array w/ name, tables, etc.
end

## pp schemas

json = JSON.pretty_generate( data )
## puts json

File.open( 'database.json', 'w') do |f|
  f.write JSON.pretty_generate( data )
end



####
# build symbol index hash

symbols = {}

letters = %w(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z)

## add a to z [26 entries]

letters.each do |letter|
  symbols[letter] = {
      name:   letter,
      tables: [],
      columns: []
  }
end



con.tables.sort.each do |name|

  table_key  = name[0].upcase
  symbols[table_key][:tables] << name
  
  con.columns( name ).each do |col|
    col_key = col.name[0].upcase
    symbols[col_key][:columns] << "#{col.name} in #{name}"
  end
end


data = []
symbols.each do |k,v|
  data << v     # turn data json into an array of letters (ever letter is a hash w/ name,tables,columns,etc.)
end

File.open( 'symbols.json', 'w') do |f|
  f.write JSON.pretty_generate( data )
end
