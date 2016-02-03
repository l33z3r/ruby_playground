require './chromosome.rb'

POPULATION_SIZE = 100

class Population

  attr_accessor :chromosomes

  def initialize
    self.chromosomes = Array.new
  end

  def inspect
    chromosomes.join(" ")
  end

  def seed!
    chromosomes = Array.new
    1.upto(POPULATION_SIZE).each do
      chromosomes << Chromosome.new
    end

    self.chromosomes = chromosomes
  end

  def count
    chromosomes.count
  end

  def fitness_values
    chromosomes.collect(&:fitness)
  end

  def total_fitness
    fitness_values.inject{|total, value| total + value }
  end

  def max_fitness
    fitness_values.max
  end

  def average_fitness
    total_fitness.to_f / chromosomes.length.to_f
  end

  def select
    rand_selection = rand(total_fitness)

    total = 0
    chromosomes.each_with_index do |chromosome, index|
      total += chromosome.fitness
      return chromosome if total > rand_selection || index == chromosomes.count - 1
    end
  end
end
