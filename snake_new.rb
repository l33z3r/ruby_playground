#!/usr/bin/ruby
require 'curses'
include Curses

require 'ai4r'

Thread::abort_on_exception = true

class Snake
  LOST_STRING = 'You LOST'

  attr_accessor :win

  def initialize
    @net = Ai4r::NeuralNetwork::Backpropagation.new([6, 5, 5, 4])

    init_screen
    cbreak
    noecho						  # does not show input of getch
    stdscr.nodelay = 1 	# the getch doesnt system_pause while waiting for instructions
    stdscr.keypad = true
    curs_set(0)					# the cursor is invisible.

    @win = Window.new(lines, cols, 0, 0) #set the playfield the size of current terminal window
    @title = 'Snake'

    @pos_y = [5,4,3,2,1]
    @pos_x = [1,1,1,1,1]

    @dir = :right
    @pause = true
    @snake_len = 3
    @game_speed = 0.2
    @start_time = Time.now.to_i
    @speed_incremented = false
    @display_speed = 0
    @game_score = 0
    @end_game = false
    @ticks = 0

    @border_wall = ?|
    @border_roof = ?-

    make_food(lines, cols)

    @simulate = false
  end

  def draw
    return if @end_game

    win.box(@border_wall, @border_roof)				# border

    win.setpos(@food_x, @food_y)
    win.addstr('*')								#draw food

    win.setpos(0, 3)
    win.addstr(@training_text)

    win.setpos(0, cols/2 - @title.length/2)
    win.addstr(@title)

    win.setpos(0, cols - 28)
    win.addstr("Current Guess: #{@current_guess}")

    win.setpos(lines - 1, 3)
    win.addstr("Simulating: #{@simulate ? 'Yes' : 'No'}")

    win.setpos(lines - 1, cols - 12)
    win.addstr("Score: #{@game_score}")

    #draw the snake and its tail
    (0..@snake_len).each do |i|
      win.setpos(@pos_x[i],@pos_y[i])
      win.addstr(i == 1 ? '#' : '+')
    end

    win.refresh
  end

  def process_world
    # time does not stop ticking when paused. this is a bit of logic. we use time only for score.
    @time_offset = Time.now.to_i - @start_time

    process_direction
    remember_tail
    adjust_speed_of_play
    check_collision
    check_ate_food
  end

  def start
    begin
      loop do
        process_world
        draw
        read_input
        tick
        check_end_game
        clear_window
      end
    ensure
      close_screen
    end
  end

  def tick
    if !@pause
      @ticks += 1
    end

    # actually account for speed. the sleep here introduces FPS.
    sleep( (@dir == :left or @dir == :right) ? @game_speed/2 : @game_speed)
  end

  def check_end_game
    return unless @end_game

    clear_window

    win.setpos(lines/2, cols/2-LOST_STRING.length/2)
    win.addstr(LOST_STRING)
    win.refresh

    sleep(2)

    exit
  end

  def make_food(max_h, max_w)
    @food_y = rand(2..max_w-2)
    @food_x = rand(1..max_h-2)
  end

  def read_input
    @old_dir = @dir

    case getch
      when ?P, ?p
        @pause = !@pause

        if @pause
          @game_speed = 0.2
        else
          @game_speed = 0.01
        end
      when ?d
        File.open('./snake_nn_dump.txt', 'w') { |file| file.write(Marshal.dump(@net)) }
      when ?l
        @net = Marshal.load(File.read('./snake_nn_dump.txt'))
      when ?n
        @net = Ai4r::NeuralNetwork::Backpropagation.new([6, 5, 5, 4])
      when ?s
        @simulate = !@simulate
    end

    if !@simulate
      make_forced_calculated_dir
    end

    @new_dir = @dir

    old_state = dir2array(@old_dir) + [@pos_x[0] <=> @food_x, @pos_y[0] <=> @food_y]
    # @current_guess = @net.eval(old_state).map { |val| val.round(2) }
    @current_guess = array2dir(@net.eval(old_state).map { |val| val.round })

    @net.train(old_state, dir2array(@new_dir))
    @training_text = "Trained network #{old_state} => #{dir2array(@new_dir)}"

    if @simulate
      @dir = @current_guess
    end
  end

  def make_forced_calculated_dir
    if @dir == :down
      if @food_x <= @pos_x[0]
        #must turn left or right
        if @food_y >= @pos_y[0]
          @dir = :right
        elsif @food_y < @pos_y[0]
          @dir = :left
        end
      end
    elsif @dir == :up
      if @food_x >= @pos_x[0]
        #must turn left or right
        if @food_y >= @pos_y[0]
          @dir = :right
        elsif @food_y < @pos_y[0]
          @dir = :left
        end
      end
    elsif @dir == :left
      if @food_y >= @pos_y[0]
        #must turn up or down
        if @food_x >= @pos_x[0]
          @dir = :down
        elsif @food_x < @pos_x[0]
          @dir = :up
        end
      end
    elsif @dir == :right
      if @food_y <= @pos_y[0]
        #must turn up or down
        if @food_x >= @pos_x[0]
          @dir = :down
        elsif @food_x < @pos_x[0]
          @dir = :up
        end
      end
    end
  end

  def dir2array(dir)
    return [1, 0, 0, 0] if dir == :down
    return [0, 1, 0, 0] if dir == :up
    return [0, 0, 1, 0] if dir == :left
    return [0, 0, 0, 1] if dir == :right
  end

  def array2dir(array)
    return :down if array == [1, 0, 0, 0] and @dir != :up
    return :up if array == [0, 1, 0, 0] and @dir != :down
    return :left if array == [0, 0, 1, 0] and @dir != :right
    return :right if array == [0, 0, 0, 1] and @dir != :left

    # if @simulate
    #   puts @dir
    #   sleep(2)
    # end

    # The network falls back on this if it can't guess
    if @dir == :up
      return :left
    elsif @dir == :down
      return :right
    elsif @dir == :left
      return :down
    elsif @dir == :right
      return :up
    end
  end

  def process_direction
    case @dir
      when :up then @pos_x[0] -= 1
      when :down  then @pos_x[0] += 1
      when :left  then @pos_y[0] -= 1
      when :right then @pos_y[0] += 1
    end
  end

  def remember_tail
    i = @snake_len + 1

    while i > 0 do
      @pos_x[i] = @pos_x[i - 1]
      @pos_y[i] = @pos_y[i - 1]
      i -= 1
    end

  end

  def adjust_speed_of_play
    if ((@snake_len % 10 == 0) or (@time_offset % 60 == 0))
      unless @speed_incremented
        @game_speed -= (@game_speed * 0.1) unless @game_speed < 0.05
        @speed_incremented = true
        @display_speed += 1
      end
    else
      @speed_incremented = false
    end
  end

  def check_collision
    #check collision with border
    if @pos_y[0] == cols - 1 or @pos_y[0] == 0 or @pos_x[0] == lines-1 or @pos_x[0] == 0
      @end_game = true
    end

    #check collision with self
    (2..@snake_len).each do |i|
      if @pos_y[0] == @pos_y[i] and @pos_x[0] == @pos_x[i]
        @end_game = true
      end
    end
  end

  def check_ate_food
    if @pos_y[0] == @food_y and @pos_x[0] == @food_x
      make_food(lines, cols)
      # @snake_len += 1
      @game_score += @display_speed
    end
  end

  def clear_window
    win.clear
    win.refresh
  end
end

@snake = Snake.new.start


