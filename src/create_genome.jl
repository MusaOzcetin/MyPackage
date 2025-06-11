module CreateGenome

using ..Types


export create_genome
"""
    create_genome(id, num_inputs, num_outputs) → Genome

Instantiate a `Genome` with an `id` Id, `num_inputs` input nodes and
`num_outputs` output nodes.  
Creates two hardcoded connections—from input 1 and input 2 to the first output—
each with a random weight.

# Arguments
- `id::Int`: Unique genome identifier.
- `num_inputs::Int`: Number of input nodes.
- `num_outputs::Int`: Number of output nodes.

# Returns
A `Genome(id, nodes, connections)` where `nodes` is a `Dict{Int,Node}` of all
input/output nodes, and `connections` is a `Dict{(Int,Int),Connection}` with
two initial connections (innovation 1 and 2).

Network Structure:

2 input neurons
1 output neuron

No hidden layer
"""
function create_genome(id::Int, num_inputs::Int, num_outputs::Int)
    nodes = Dict{Int,Node}()
    connections = Dict{Tuple{Int,Int},Connection}()

    # create input nodes
    for i in 1:num_inputs
        nodes[i] = Node(i, :input)
    end

    # create output nodes
    for i in 1:num_outputs
        nid = num_inputs + i
        nodes[nid] = Node(nid, :output)
    end

    # Connection from input 1 to output 1 and input 2 to output 1
    connections[(1, num_inputs + 1)] = Connection(1, num_inputs + 1, randn(), true, 1)
    connections[(2, num_inputs + 1)] = Connection(2, num_inputs + 1, randn(), true, 2)

    return Genome(id, nodes, connections)
end

end