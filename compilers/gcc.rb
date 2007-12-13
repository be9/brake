#require 'general'

module Brake
  module Compilers
    class Gcc < Compiler
      include Brake::Checks

      def detect
        @options[:only_c] ||= false

        cc = ENV["CC"] || find_program("gcc") || find_program("cc")

        unless cc
          log "GNU C compiler not found", :fatal
          return false
        end

        @conf[:cc] = cc

        logn "Checking for working C compiler... "

        true
      end
    end

    register :gcc, Gcc
  end
end

<<FROMCMAKE




FROMCMAKE
