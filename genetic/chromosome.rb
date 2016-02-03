NUM_BITS = 64

class Chromosome
  attr_accessor :genes

  def initialize(genes = "")
    if genes == ""
      self.genes = (1..NUM_BITS).map{ rand(2) }.join
    else
      self.genes = genes
    end
  end

  def to_s
    genes.to_s
  end

  def count
    genes.count
  end

  def fitness
    genes.count("1")
  end

  def mutate!
    mutated = ""
    0.upto(genes.length - 1).each do |i|
      allele = genes[i, 1]
      if rand <= MUTATION_RATE
        mutated += (allele == "0") ? "1" : "0"
      else
        mutated += allele
      end
    end

    self.genes = mutated
  end

  def &(other)
    locus = rand(genes.length) + 1

    child1 = genes[0, locus] + other.genes[locus, other.genes.length]
    child2 = other.genes[0, locus] + genes[locus, other.genes.length]

    return [
        Chromosome.new(child1),
        Chromosome.new(child2),
    ]
  end
end
