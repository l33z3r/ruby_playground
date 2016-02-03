require 'celluloid/current'
require 'digest/sha1'
require 'benchmark'

class SHAPutter
  include Celluloid

  def initialize(filename)
    @filename = filename
  end

  def output(checksum_future)
    puts "#{@filename} - #{checksum_future.value}"
  end

  def checksum
    a = ''
    10_00_000.times{|i| a = i.to_s + a}
    @file_contents = File.read(@filename)

    Digest::SHA1.hexdigest @file_contents
  end

end

benchy = Benchmark.measure do
  files = %w(dofork.rb dofork.rb vec3.rb dof ork.rb dofork.rb dofork.rb vec3.rb dofork.rb)

  futures = []

  files.each do |file|
    sha = SHAPutter.new file
    checksum_future = sha.future :checksum
    futures << checksum_future
    sha.async.output checksum_future
  end

  results = futures.map(&:value)
  puts results
end

puts benchy

# MRI:    24.100000  24.820000  48.920000 ( 49.265441)
# JRuby:  50.730000   0.610000  51.340000 ( 16.218196)
