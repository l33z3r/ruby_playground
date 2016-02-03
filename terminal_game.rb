#!/usr/bin/ruby
require 'curses'
include Curses

class Snake
  LOST_STRING = 'You LOST'

  attr_accessor :win

  def initialize
    init_screen
    cbreak
    noecho						  # does not show input of getch
    stdscr.nodelay = 1 	# the getch doesnt system_pause while waiting for instructions
    curs_set(0)					# the cursor is invisible.

    @win = Window.new(lines, cols, 0, 0) #set the playfield the size of current terminal window
    @title = 'Snake'

    @pos_y = [5,4,3]
    @pos_x = [1,1,1]

    @dir = :right
    @pause = false
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

    @input_reader_thread = Thread.new do
      loop do
        break if @end_game
        read_input
        sleep(0.1)
      end
    end
  end

  def draw
    win.box(@border_wall, @border_roof)				# border

    win.setpos(@food_x, @food_y)
    win.addstr('*')								#draw food

    win.setpos(0, 3)
    win.addstr("Snake Length: #{@snake_len}")

    win.setpos(0, cols/2 - @title.length/2)
    win.addstr(@title)

    win.setpos(0, cols - 12)
    win.addstr("Ticks: #{@ticks}")

    win.setpos(lines - 1, 3)
    win.addstr("Speed: #{@display_speed}")

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

    change_of_dir
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
        tick
        pause
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

    @input_reader_thread.join

    clear_window

    win.setpos(lines/2, cols/2-LOST_STRING.length/2)
    win.addstr(LOST_STRING)
    win.refresh

    sleep(2)

    exit
  end

  def check_pause
    if @pause
      sleep(0.5)
      pause?
    end
  end

  def make_food(max_h, max_w)
    @food_y = rand(2..max_w-2)
    @food_x = rand(1..max_h-2)
  end

  def read_input
    case getch
      when ?Q, ?q
        exit
      when ?W, ?w
        @dir = :up if @dir != :down
      when ?S, ?s
        @dir = :down if @dir != :up
      when ?D, ?d
        @dir = :right if @dir != :left
      when ?A, ?a
        @dir = :left if @dir != :right
      when ?P, ?p
        @pause = @pause ? false : true
    end
  end

  def change_of_dir
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
      @snake_len += 1
      @game_score += @display_speed
    end
  end

  def clear_window
    win.clear
    win.refresh
  end
end

@snake = Snake.new.start


