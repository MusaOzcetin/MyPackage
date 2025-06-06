module ForwardPass

using ..Types
using ..CreateGenome

export forward_pass

"""
    forward_pass(genome::Genome, input::Vector{Float64}) → Float64

Compute the output of a simple feedforward network defined by `genome`.  
Assumes a hardcoded structure where each input node `i` may connect to output node ID `3`.  
For each enabled connection `(i, 3)`, multiplies `input[i]` by the connection’s weight and sums
the results. Applies a sigmoid activation to the final sum.

# Arguments
- `genome::Genome`: The genome containing connection definitions and weights.
- `input::Vector{Float64}`: A vector of input values; its length should match the number of input nodes.

# Returns
- `Float64`: The sigmoid-activated output of the network (between 0 and 1).
"""
function forward_pass(genome::Genome, input::Vector{Float64})::Float64
    output_sum = 0.0
    for i in 1:length(input)
        conn_key = (i, 3) # assuming output node is always 3 (see first cell; hardcoded)
        if haskey(genome.connections, conn_key) # if there is edge from i to 3 (op) 
            conn = genome.connections[conn_key]
            if conn.enabled # and if connection is enabled
                output_sum += input[i] * conn.weight # add input*weight to output
            end
        end
    end
    return 1.0 / (1.0 + exp(-output_sum)) # apply sigmoid (because why not)
end

end