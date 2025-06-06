module Fitness

using ..Types
using ..ForwardPass

export evaluate_fitness

"""
    evaluate_fitness(genome::Genome) → Float64

Evaluate a `Genome`’s performance on the XOR task by summing squared errors 
for all four input–output pairs and returning the negative total error.

# Arguments
- `genome::Genome`: The genome whose neural network weights are tested on XOR.

# Returns
- `Float64`: The negative sum of squared errors over the four XOR cases.
  (Higher value ⇒ lower error ⇒ better fitness.)
"""
function evaluate_fitness(genome::Genome)::Float64
    xor_data = [([0.0, 0.0], 0.0), ([0.0, 1.0], 1.0), ([1.0, 0.0], 1.0), ([1.0, 1.0], 0.0)]

    total_error = 0.0

    for (x, target) in xor_data
        output = forward_pass(genome, x) # compute forward_pass
        total_error += (output - target)^2  # compute error
    end

    return -total_error # the lower the error, the higher the fitness
end

end
