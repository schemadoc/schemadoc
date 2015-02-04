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

        ### use -c and --config / why? why not??
        ### use -n and --name   / why? why not??

        cmd.on( '-f', '--file NAME', "Configuration name (default is '#{opts.config_name}')" ) do |s|
          opts.config_name = s
        end
        cmd.on( '-d', '--dir PATH', "Configuration path (default is '#{opts.config_path}')" ) do |s|
          opts.config_path = s
        end

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
  schemadoc -f football.yml

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

      config = YAML.load_file( "#{opts.config_path}/#{opts.config_name}" )
      pp config 

      worker = Worker.new( config ).run()

      puts 'Done.'

    end   # method run
    
  end # class Runner

end  # module SchemaDoc

