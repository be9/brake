#require 'general'

module Brake
  module Compilers
    class Gcc < Compiler
      def initialize(name, options)
        super
        probe unless probed?
      end

      def probe
        print "-- probing gcc\n"

        probe_ok
      end
    end

    register :gcc, Gcc
  end
end
