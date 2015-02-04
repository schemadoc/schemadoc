# encoding: utf-8


module SchemaDoc

  class Opts

    def config_name=(value)
      @config_name = value
    end

    def config_name
      @config_name || 'schemadoc.yml'
    end

    def config_path=(value)
      @config_path = value
    end

    def config_path
      @config_path || '.'
    end


    def output_path=( value )
      @output_path = value
    end

    def output_path
      @output_path || '.'
    end

  end # class Opts

end  # module SchemaDoc
