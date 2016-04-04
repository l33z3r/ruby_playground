require 'uri'
require 'net/http'

@threads = []

@num_threads = 10
@hit_times = 10

(1..@num_threads).each do |num|
  @threads << Thread.new do
    (1..@hit_times).each do |hit_num|
      # uri = URI('http://homer-staging.sportsinteraction.com/evolution/debit?userId=40301&sid=e4098351b443013224a400155da8400b&currency=EUR&transaction%5Bamount%5D=1&transaction%5BrefId%5D=1234')
      uri = URI('http://localhost:3100/evolution/debit?userId=40301&sid=e4098351b443013224a400155da8400b&currency=EUR&transaction%5Bamount%5D=1&transaction%5BrefId%5D=1234')
      @response = Net::HTTP.get(uri)
      puts "Resp: #{@response}"
    end
  end
end

@threads.map(&:join)

puts 'Done'
