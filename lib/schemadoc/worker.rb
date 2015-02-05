# encoding: utf-8

###
# generate
#  json
#   for schema doc
#  (see simple datasets package schema from okfn ???)


module SchemaDoc

class Worker

  def initialize( config )
    ## split into db config (for connection) and
    ## schemadoc config
    
    @config    = {}
    @db_config = {}

    config.each do |k,v|
      if k == 'database'
        @db_config = v   # note: discard key; use hash as connection spec
      else
        @config[ k ] = v
      end
    end

    puts "database connection spec:"
    pp @db_config
  end


  def connect
    @con = AbstractModel.connection_for( @db_config )
  end

  def dump_schema
    @con.tables.sort.map do |name|
       puts "#{name} : #{name.class.name}"
    end
    puts ''

    @con.tables.sort.each do |name|
      puts "#{name}"
      puts "-" * name.size

      @con.columns( name ).each do |col|
        puts "  #{col.name} #{col.sql_type}, #{col.default}, #{col.null} : #{col.class.name}"
      end
      puts ''
    end
  end

  def build_schema
    ####
    # build schema hash

    schemas = {}

    @con.tables.sort.each do |name|

      t = { name: name,
            columns: []
          }
      @con.columns( name ).each do |col|
        t[:columns] << {
           name:    col.name,
           type:    col.sql_type.downcase,   # note: use integer (instead of INTEGER)
           default: col.default,
           null:    col.null
        }
      end

      schema_name = find_schema_for_table(name)
      puts "add '#{name}' to schema '#{schema_name}'"

      schema = schemas[schema_name]
      if schema.nil?
        # note: use schema_name from config (do NOT use key - might be different)
        schema = { name: schema_name, tables: [] }
        schemas[schema_name] = schema
      end
      schema[:tables] << t
    end

    data = { schemas: [] }
    schemas.each do |k,v|
      data[:schemas] << v   ## turn schemas into an array w/ name, tables, etc.
    end
    
    data
  end


  def build_index
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

    @con.tables.sort.each do |name|

      table_key  = name[0].upcase
      symbols[table_key][:tables] << name

      @con.columns( name ).each do |col|
        col_key = col.name[0].upcase
        cols_ary = symbols[col_key][:columns]

        ## search for column name
        col_hash = cols_ary.find { |item| item[:name] == col.name }
        if col_hash.nil?
          col_hash = { name: col.name, tables: [] }
          cols_ary << col_hash
        end

        col_hash[:tables] << name  
      end
    end

    ## sort tables, cols and (in tables)
    symbols.each do |k,h|
      h[:tables] = h[:tables].sort

      h[:columns] = h[:columns].sort { |l,r| l[:name] <=> r[:name] }
      h[:columns].each { |col| col[:tables] = col[:tables].sort }
    end

    data = []
    symbols.each do |k,v|
      data << v     # turn data json into an array of letters (ever letter is a hash w/ name,tables,columns,etc.)
    end

    data
  end


  def run( opts={} )
    connect()
    dump_schema()

    schema = build_schema()
    index  = build_index()

    ## pp schema

    File.open( 'database.json', 'w') do |f|
      f.write JSON.pretty_generate( schema )
    end

    File.open( 'symbols.json', 'w') do |f|
      f.write JSON.pretty_generate( index )
    end
  end


private

  class AbstractModel < ActiveRecord::Base
    self.abstract_class = true   # no table; class just used for getting db connection

    def self.connection_for( key_or_spec )
      establish_connection( key_or_spec )
      connection
    end
  end  # class AbstractModel


  def find_schema_for_table( name )

    @config.each do |k,h|
      tables = h['tables'] || []
      if tables.include?( name )
        return k
      end
    end

    ## no entry found; assume default schema (e.g. first schema listed in config)
    @config.keys.first
  end

end

end # module SchemaDoc
