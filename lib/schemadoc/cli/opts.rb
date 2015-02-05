# encoding: utf-8


module SchemaDoc

  class Opts

    def output_path=( value )
      @output_path = value
    end

    def output_path
      @output_path || '.'
    end

  end # class Opts

end  # module SchemaDoc

