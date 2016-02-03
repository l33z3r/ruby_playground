require './island.rb'

class Colony
  attr_accessor :islands

  def initialize(num_islands = 4)
    @islands = []

    (1..num_islands).each do |num|
      @islands << Island.new("Island#{num}")
    end

    @islands.each_with_index do |island, index|
      left_neighbour_index = index == 0 ? @islands.length - 1 : index - 1
      left_neighbor = @islands[left_neighbour_index]
      right_neighbour_index = index == @islands.length - 1 ? 0 : index + 1
      right_neighbor = @islands[right_neighbour_index]
      island.set_neighbors(left_neighbor, right_neighbor)
    end
  end

  def simulate
    Thread.new do
      sleep 60
      @islands.map(&:stop_simulation)
      puts 'Finished Simulation'
    end

    @islands.map(&:simulate).each(&:join)
  end
end

Colony.new.simulate


