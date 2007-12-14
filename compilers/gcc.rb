require 'checks'

module Brake
  module Compilers
    class GccException < Exception; end

    class Gcc < Compiler
      include Brake::Checks

      def detect
        @options[:only_c] ||= false

        cc = @options[:cc] || ENV["CC"] || find_program("gcc") || find_program("cc")

        raise GccException, "GNU C compiler not found" unless cc

        @conf[:cc] = cc

        logn "Checking for working C compiler... "
      
        raise GccException, "Compiler didn't produce a working program" 
          unless try_compile_and_run("int main() { return 0; }\n", "c", self)

      rescue => e
        log e.message, :fatal

        false
      else
        true
      end
    end

    register :gcc, Gcc
  end
end

<<FROMCMAKE




FROMCMAKE
