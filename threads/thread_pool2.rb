require 'thread'

class ThreadPool
  def initialize(max_size)
    @pool = []
    @max_size = max_size
    @pool_mutex = Mutex.new
    @pool_cv = ConditionVariable.new
  end

  def dispatch(*args)
    Thread.new do
      # Wait for space in the pool
      @pool_mutex.synchronize do
        while @pool.size >= @max_size
          print "Pool is full; waiting to run #{args.join(',')}...\n"
          # Sleep until another thread calls @pool_cv.signal
          @pool_cv.wait(@pool_mutex)
        end
      end

      @pool << Thread.current

      begin
        yield(*args)
      rescue => e
        exception(thread, e, *args)
      ensure
        @pool_mutex.synchronize do
          # Remove the thread from pool
          @pool.delete(Thread.current)
          # Signal the next waiting thread that there's a space in the pool.
          @pool_cv.signal
        end
      end
    end
  end

  def shutdown
    @pool_mutex.synchronize do
      until @pool.empty?
        @pool_cv.wait(@pool_mutex)
      end
    end
  end

  def exception(thread, exception, *original_args)
    puts "Exception in thread #{thread}: #{exception}"
  end
end

pool = ThreadPool.new(4)

1.upto(50) do |i|
  pool.dispatch(i) do |i|
    print "Job #{i} started. \n"

    a = 0

    10_000.times do
      10_000.times do
        a += 1
      end
    end

    print "Job #{i} stopped. \n"
  end
end

pool.shutdown
