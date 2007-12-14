require 'checks'
require 'compilers'
require 'escape'

module Brake
  module Compilers
    class GccException < Exception; end

    class Gcc < Brake::Compilers::Compiler
      include Brake::Checks

      def detect
        @options[:only_c] ||= false

        cc = @options[:cc] || ENV["CC"] || find_program("gcc") || find_program("cc")

        raise GccException, "GNU C compiler not found" unless cc

        @conf[:cc] = cc

        logn "Checking C compiler... "

        unless try_compile_and_run("test1", "int main() { return 0; }\n", "c", self)
          raise GccException, "Compiler didn't produce a working program"
        end

        logc "seems working"

      rescue GccException => e
        logc e.message, :fatal

        false
      else
        true
      end

      def oneliner(source, target)
        source = Shell.escape(source)
        target = Shell.escape(target)

        results = `#{@conf[:cc]} -o #{target} #{source}`
        if $? != 0
          log "Compiler aborted (#{results})", :fatal
          false
        else
          true
        end
      end
    end

    #register :gcc, Gcc
  end
end
