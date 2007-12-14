module Brake
  ON_WINDOWS = RUBY_PLATFORM =~ /(:?mswin|mingw32)/

  module Logging
    # Log line
    def log(s, level = :normal)
       logn(s)
       print "\n"
    end

    # Log, but stay on the same line 
    def logn(s, level = :normal)
      print "-- " + s
    end
    
    # Continue log line
    def logc(s)
      print s, "\n"
    end
  end
end
