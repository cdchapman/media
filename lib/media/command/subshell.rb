require 'open3'
require 'forwardable'

module Media
  module Command
    class Subshell
      extend Forwardable
      def_delegators :'wait_thread.value', :pid, :exitstatus, :termsig, :stopsig
    
      attr_reader :out, :error, :wait_thread
    
      def initialize(args)
        @cmd = Array(args.fetch(:cmd))
        @out = ''
        @error = ''
      end
    
      def call
        ENV['CLICOLOR'] = nil
        ENV['AV_LOG_FORCE_COLOR'] = nil
        
        _, o, e, @wait_thread = Open3.popen3(*@cmd)
        
        while wait_thread.alive?
          next unless IO.select([o, e], nil, nil, 1)
          out << read(io: o)
          error << read(io: e).tap {|e| yield e.strip if block_given? }
        end
        
        self
      end  
        
      def read(io:, buffer: 65536)
        io.read_nonblock(buffer)
      rescue EOFError, IO::WaitReadable
        ''
      end
          
      def success?
        exitstatus == 0
      end
    end
  end
end