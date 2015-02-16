# encoding: utf-8


# more core and stlibs

require 'optparse'

# our own code (for command line interface/cli)

require 'schemadoc/cli/opts'


module SchemaDoc

  class Runner

    include LogUtils::Logging

    attr_reader :opts
        
    def initialize
      @opts = Opts.new
    end
    
    def run( args )
      opt=OptionParser.new do |cmd|

        cmd.banner = "Usage: schemadoc [options]"

        cmd.on( '-o', '--output PATH', "Output path (default is '#{opts.output_path}')" ) do |s|
          opts.output_path = s
        end

        # todo: find different letter for debug trace switch (use v for version?)
        cmd.on( '-v', '--verbose', 'Show debug trace' )  do
           logger = LogUtils::Logger.root
           logger.level = :debug
        end

      usage =<<EOS
 
schemadoc #{VERSION} - Lets you document your database tables, columns, etc.

#{cmd.help}

Examples:
  schemadoc
  schemadoc football.yml

Further information:
  https://github.com/rubylibs/schemadoc

EOS

        ## todo: also add -?  if possible as alternative
        cmd.on_tail( '-h', '--help', 'Show this message' ) do
           puts usage
           exit
        end
      end

      opt.parse!( args )
  
      puts SchemaDoc.banner

      arg = args[0] || './schemadoc.yml'
      config = YAML.load_file( arg )
      pp config

      ## check for .rb file w/ same name but .rb extension
      ##  require/load if present
      boot_path = arg.sub( '.yml', '.rb' )
      if File.exists?( boot_path )
        puts "try to boot (load) '#{boot_path}'..."

        ## note: for now always add ./ current workdir
        ##   fix - check if path is absolute; if not only add ./ current if not absolute
        require "./#{boot_path}"
        puts 'ok'
      end

      if defined?(MODELS)
        models = MODELS
        models.each do |model|         # double check model classes if present (loaded)
          puts "#{model.name}... ok"
        end
      else
        models = []
      end

      worker = Worker.new( config, models ).run

      puts 'Done.'

    end   # method run
    
  end # class Runner

end  # module SchemaDoc

