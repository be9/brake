require 'logging'

module Brake
  module Compilers
    class Compiler
      include Brake::Logging

      attr_reader :conf

      def initialize(name, options = {})
        @name = name.to_s
        @options = options
        @conf = {}
      end

      def probed?
        cache['compilers'][@name][:probed] rescue false
      end

      def probe
        unless probed?
          @conf = {}

          if detect
            cache['compilers'][@name] = @conf.merge({:probed => true})
            cache.save
          end
        end
      end

      def cache
        Brake.cache
      end

      def known_extensions
        []
      end
    end
  end
end
