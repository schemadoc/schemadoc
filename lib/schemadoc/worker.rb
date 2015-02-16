# encoding: utf-8

###
# generate
#  json
#   for schema doc
#  (see simple datasets package schema from okfn ???)


module SchemaDoc

class Worker

  def initialize( config, models=[] )
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
    
    @models = models
  end


  def connect
    ##@con = AbstractModel.connection_for( @db_config )

    ActiveRecord::Base.establish_connection( @db_config )
    @con = ActiveRecord::Base.connection
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


  def dump_models
    @models.each do |model|
      ## pp model

      puts model.name
      puts "=" * model.name.size
      puts "  table_name: #{model.table_name}"
      pp model.columns

      ## check assocs
      assocs = model.reflections.values
      ## pp assocs
      assocs.each do |assoc|
        puts "#{assoc.macro} #{assoc.name}"
        puts "options:"
        pp assoc.options
      end
    end
  end


  def build_models
    #########################
    # build models hash
    
    models = []

    @models.each do |model|

      puts model.name
      puts "=" * model.name.size

      m = {
        name: model.name,     ## todo: split into name and module/package name ?? 
        table_name: model.table_name,
        columns: [],
        assocs: [],
      }

      model.columns.each do |column|
        c = {
          name:     column.name,
          null:     column.null,
          default:  column.default,
          sql_type: column.sql_type,
          cast_type: column.cast_type.class.name,
        }
        m[:columns] << c
      end

      ## check assocs
      assocs = model.reflections.values
      assocs.each do |assoc|
        a = {
          macro:   assoc.macro,     ## rename to rel or something - why, why not??
          name:    assoc.name,
          options: assoc.options    ## filter options - why, why not??
        }
        m[:assocs] << a
      end

      models << m
    end # each model
    models
  end  # method build_models


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


  def models_to_yuml( models )

    ## todo: move to script !!!
    ##   check
    ##   how to deal w/ singular,plural,
    ##   add to model
    ##    singular,plural  - to keep it simple???
    ##   use name and full_name and module ??
    ##  e.g. BeerDb::Model::Brewery ???

    buf = ''
    models.each do |model|

      assocs = model[:assocs]
      if assocs.empty?
        buf << "// skipping #{model[:name]}; no assocs found/n"
        next
      end

      assocs.each do |assoc|
        ## skip assocs w/ option through for now
        if assoc[:options][:through]
          buf << "// skipping assoc #{assoc[:macro]} #{assoc[:name]} w/ option through\n"
          next
        end

        buf << "[#{model[:name]}] - [#{assoc[:name]}]\n"
      end
    end

    buf
  end


  def run( opts={} )
    connect()
    dump_schema()
    dump_models()

    models = build_models()
    pp models

    schema = build_schema()
    index  = build_index()

    ## pp schema

    File.open( 'database.json', 'w') do |f|
      f.write JSON.pretty_generate( schema )
    end

    File.open( 'models.json', 'w') do |f|
      f.write JSON.pretty_generate( models )
    end
    
    ### fix: move to script !!!
    File.open( 'models.yuml', 'w' ) do |f|
      f.write models_to_yuml( models )
    end

    File.open( 'symbols.json', 'w') do |f|
      f.write JSON.pretty_generate( index )
    end
  end


private

  ###
  ## fix: not really needed - remove ???
  ##   just use ActiveRecord::Base.establish_connection() directly ??

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
