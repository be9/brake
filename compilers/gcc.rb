require 'checks'
require 'compilers'
require 'escape'

module Brake
  module Compilers
    class GccException < Exception; end

    class Gcc < Brake::Compilers::Compiler
      include Brake::Checks

      def detect
        @options[:detect_cxx] ||= false

        cc = @options[:cc] || ENV["CC"] || find_program("gcc") || find_program("cc")

        raise GccException, "GNU C compiler not found" unless cc

        @conf[:cc] = cc

        logn "Checking C compiler... "

        unless try_compile_and_run("testc", "int main() { return 0; }\n", "c", self)
          raise GccException, "Compiler didn't produce a working program"
        end

        logc "seems working"

        if @options[:detect_cxx]
          cxx = @options[:cxx] || ENV["CXX"] || find_program("g++") || find_program("c++")
        
          raise GccException, "GNU C++ compiler not found" unless cxx

          @conf[:cxx] = cxx
        
          logn "Checking C++ compiler... "
          
          unless try_compile_and_run("testcxx", "class A{}; int main() { return 0; }\n", "cxx", self)
            raise GccException, "Compiler didn't produce a working program"
          end

          @conf[:cxx_probed] = true 
          logc "seems working"
        end

      rescue GccException => e
        logc e.message, :fatal

        false
      else
        true
      end

      def oneliner(source, target)
        compiler = @conf[compiler_for_source_file(source)]
        source = Shell.escape(source)
        target = Shell.escape(target)

        results = `#{compiler} -o #{target} #{source}`
        if $? != 0
          #log "Compiler aborted (#{results})", :fatal
          false
        else
          true
        end
      end
      
      def known_extensions
        if probed?
          exts = %w(c)

          exts += %w(cpp cxx C cc) if @conf[:cxx_works]

          exts
        else
          []
        end
      end

      def compiler_for_source_file(source)
        ext = File.extname(source)[1..-1]

        if ext == "c"
          :cc
        elsif ["cxx","cpp","c++","cc","C"].include? ext
          :cxx
        else
          nil
        end
      end
    end

    #register :gcc, Gcc
  end
end
