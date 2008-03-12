module Brake
  class CompilerPool
    def initialize
      @compilers = {}
    end

    def compiler(type, options = {})
      type = type.to_s
   
      require "compilers/#{type}"

      @compilers[type] = 
    end

    def loaded?(name)
      @compilers.include? name.to_s
    end
  end
end
