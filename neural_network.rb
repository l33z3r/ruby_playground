require 'ai4r'

# Create the network with 4 inputs, 1 hidden layer with 3 neurons,
# and 2 outputs
net = Ai4r::NeuralNetwork::Backpropagation.new([2, 4, 4, 4, 2])

# Train the network
10_000.times do |i|
  net.train([50, 25], [1, 0])
  net.train([100, 50], [1, 0])
  net.train([25, 50], [0, 1])
  net.train([50, 100], [0, 1])
end

def neval(net, input)
  val = net.eval input
  puts val[0] > val[1] ? 'LEFT' : 'RIGHT'
end

# Use it: Evaluate data with the trained network
neval(net, [50, 10])
neval(net, [50, 20])
neval(net, [50, 30])
neval(net, [50, 40])
neval(net, [50, 50])
neval(net, [50, 60])
neval(net, [50, 70])
neval(net, [50, 80])
neval(net, [50, 90])
neval(net, [50, 100])


