# require 'celluloid/autostart'

# class CTest
#   include Celluloid
#
#   def foo
#     sleep 1
#     puts 'Foo'
#   end
#
# end
#
#
# 10.times do
#   CTest.new.async.foo
# end
#
# pool = CTest.pool
# puts "Pool Size: #{pool.size}"
#
# 10.times do
#   pool.async.foo
# end
#
#
#
# class FutureTest
#   include Celluloid
#
#   def foo
#     sleep 1
#     'Foo'
#   end
#
# end
#
# future = FutureTest.new.future.foo
# sleep 6
# puts future.value



# class NotificationTest
#
#   include Celluloid
#   include Celluloid::Notifications
#
#   def foo
#     sleep 2
#     publish 'done', 'Slept for 2 secs I\'m awake now'
#   end
# end
#
# class Observer
#
#   include Celluloid
#   include Celluloid::Notifications
#
#   def initialize
#     subscribe 'done', :on_completion
#   end
#
#   def on_completion(*args)
#     puts args.inspect
#   end
# end
#
#
# Observer.new
#
# NotificationTest.new.async.foo
#
#
# sleep 2


require 'celluloid/current'
require 'benchmark'


class FilePutter
  include Celluloid

  def initialize(filename)
    @filename = filename
  end

  def load_file_and_print
    a = 0

    1000.times do
      10_000.times do
        a += 1
      end
    end
    @file_contents = File.read @filename

    print
  end

  def print
    # p @file_contents
    p "Done #{Thread.current}"
  end

end

# fp = FilePutter.new "cell.rb"
# fp.load_file
# fp.print

benchy = Benchmark.measure do
  files = ["cell.rb", "cell.rb", "cell.rb", "cell.rb"]

  files.each do |file|
    fp = FilePutter.new file
    puts '!!'
    puts fp
    fp.async.load_file_and_print
  end

  puts '!!!!!!!!'
  puts Thread.list
end

puts "Benchy: #{benchy}"
