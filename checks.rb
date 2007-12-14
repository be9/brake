require 'logging'

module Brake
  module Checks
    class CheckException < Exception; end

    include Brake::Logging
    
    def find_program(program_name, paths = [])
      test_block = 
        if ON_WINDOWS then 
          proc do |f| File.exists?(f) end
        else
          proc do |f| File.executable?(f) end
        end

      logn("Checking for program #{program_name}...")

      ([''] + paths + ENV['PATH'].split(':')).each do |path|
        fname = File.join(path, program_name)
        fname += ".exe" if ON_WINDOWS
    
        if test_block.call(fname)
          fname = File.expand_path(fname)

          logc(" found at #{fname}")

          return fname
        end
      end
    
      logc(" not found")
      nil
    end

    def try_compile_and_run(name, source_code, ext, compiler)
      provide_temp_directory

      source = "./tmp/try_#{name}_#{$$}.#{ext}"
      target = "./tmp/try_#{name}_#{$$}"

      File.open(source, "w") do |f|
        f.write(source_code)
      end

      raise CheckException, "Compiler returned an error" unless compiler.oneliner(source, target)
      raise CheckException, "Compiler stated success, but no target was found" unless File.exists? target

    rescue CheckException
      return false
    else
      return true
    ensure
      File.unlink(source) if File.exists? source
      File.unlink(target) if File.exists? target
    end

    private

    def provide_temp_directory
      if File.exists? "tmp"
        raise "tmp exists, but is not a directory" unless File.directory? "tmp"
      else
        Dir.mkdir "tmp"
      end
    end
  end
end
