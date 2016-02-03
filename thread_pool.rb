require 'benchmark'
require 'thread'

POOL_SIZE = 4

jobs = Queue.new

10_000_000.times{|i| jobs.push i}

benchy = Benchmark.measure do
  workers = (POOL_SIZE).times.map do
    Thread.new do
      begin
        while x = jobs.pop(true)
          puts "x: #{x}"
        end
      rescue ThreadError
      end
    end
  end

  workers.map(&:join)
end

puts benchy

# MRI: 6.620000  18.590000  25.210000 ( 18.088650)
# JRUBY: 4.780000   2.470000   7.250000 (  3.055334)
