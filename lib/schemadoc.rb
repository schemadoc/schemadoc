# encoding: utf-8

# stdlibs

require 'pp'
require 'yaml'
require 'json'

# 3rd party gems/libs
require 'logutils'
require 'active_record'


# our own code

require 'schemadoc/version'  # let it always go first
require 'schemadoc/worker'


module SchemaDoc

  def self.main
    ## NB: only load (require) cli code if called
    require 'schemadoc/cli/runner'

    Runner.new.run( ARGV )
  end

end  # module SchemaDoc




# say hello
puts SchemaDoc.banner    if $DEBUG || (defined?($RUBYLIBS_DEBUG) && $RUBYLIBS_DEBUG)

