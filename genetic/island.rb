require './population.rb'

NUM_GENERATIONS = 10000
CROSSOVER_RATE = 0.8
MUTATION_RATE = 0.01
IMMIGRATION_COUNT = EMMIGRATION_COUNT = (Population::POPULATION_SIZE/16.0).round

class Island
  attr_accessor :name, :thread, :simulating
  attr_accessor :left_immigration_queue, :right_immigration_queue
  attr_accessor :left_emmigration_queue, :right_emmigration_queue

  def initialize(name)
    @name = name
    @left_immigration_queue = Queue.new
    @right_immigration_queue = Queue.new
  end

  def set_neighbors(left, right)
    left.set_right_emmigration_queue(@left_immigration_queue)
    right.set_left_emmigration_queue(@right_immigration_queue)
  end

  def set_right_emmigration_queue(right_emmigration_queue)
    @right_emmigration_queue = right_emmigration_queue
  end

  def set_left_emmigration_queue(left_emmigration_queue)
    @left_emmigration_queue = left_emmigration_queue
  end

  def simulate
    return @thread if @simulating

    @simulating = true

    @thread = Thread.new do
      population = Population.new
      population.seed!

      generation = 1

      loop do
        break unless @simulating

        offspring = Population.new

        while offspring.count < population.count
          parent1 = population.select
          parent2 = population.select

          if rand <= CROSSOVER_RATE
            child1, child2 = parent1 & parent2
          else
            child1 = parent1
            child2 = parent2
          end

          child1.mutate!
          child2.mutate!

          if POPULATION_SIZE.even?
            offspring.chromosomes << child1 << child2
          else
            offspring.chromosomes << [child1, child2].sample
          end
        end

        puts "#{@name}: Generation #{generation} - Average: #{population.average_fitness.round(2)} - Max: #{population.max_fitness}"

        # send some chromosomes to neighbours
        puts "Sending #{EMMIGRATION_COUNT} emmigrants"

        (1..EMMIGRATION_COUNT).each do
          @left_emmigration_queue.push(population.select)
          @right_emmigration_queue.push(population.select)
        end

        # receive some chromosomes from neighbours
        left_immigrants = []
        right_immigrants = []

        (1..@left_immigration_queue.size).each do
          left_immigrants << @left_immigration_queue.pop
        end

        (1..@right_immigration_queue.size).each do
          right_immigrants << @right_immigration_queue.pop
        end

        immigrants = left_immigrants.last(4) + right_immigrants.last(4)

        puts "Got #{immigrants.size} neighbours"

        offspring.chromosomes = offspring.chromosomes.drop(immigrants.size)
        offspring.chromosomes = offspring.chromosomes + immigrants

        puts "Offspring Size: #{offspring.chromosomes.count}"

        population = offspring

        generation += 1
      end
    end

    return @thread
  end

  def stop_simulation
    puts 'Stopping simulation'
    @simulating = false
  end
end
