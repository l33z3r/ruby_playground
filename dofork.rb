require 'benchmark'

# puts 'About To Fork'
#
# fork do
#   (1..100000).each do |num1|
#     putc 'Z'
#   end
# end
#
# (100001..200000).each do |num2|
#   putc 'Y'
# end

# puts 'Array Size'
#
# array = []
#
# 5.times.map do
#   Thread.new do
#     10.times do
#       puts Thread.current.object_id
#       array << nil
#     end
#   end
# end.each(&:join)
#
# puts array.size

puts 'Array Size'

a = 0
mutex = Mutex.new


benchy = Benchmark.measure do
  50.times.map do
    sleep(0.1)
    Thread.new do
      3.times do
        mutex.synchronize do
          x = a
          puts "#{Thread.current.object_id.to_s[-6, 6]}-#{a}\n"
          x += 1
          a = x
          x = a
          puts "#{Thread.current.object_id.to_s[-6, 6]}-#{a}\n"
          x += 1
          a = x
          x = a
          puts "#{Thread.current.object_id.to_s[-6, 6]}-#{a}\n"
          x += 1
          a = x
        end
      end
    end
  end.each(&:join)
end

puts a
puts '--------------'
puts '--------------'
puts '--------------'

puts benchy
