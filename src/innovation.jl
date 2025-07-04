module Innovation

export get_innovation_number, reset_innovation_counter!

# Global innovation number tracker (starts at 3 because 1 & 2 are used initially)
# Store the highest innovation number and increment it each time you mutate or cross over
const innovation_counter = Ref(3)

const connection_innovations = Dict{Tuple{Int,Int},Int}()

"""
    get_innovation_number(in_node::Int, out_node::Int) → Int
Returns a unique innovation number for the connection from `in_node` to `out_node`.
If this connection has been seen before, returns the previously assigned number.
Otherwise, assigns a new innovation number and stores it.
Used in NEAT to track structural mutations consistently across genomes.
!Ensures that even if two genomes both add a connection from node A → B, they will NOT get different innovation numbers.
# Returns
- `Int`: The innovation number for the (in_node, out_node) pair.
"""

function get_innovation_number(in_node::Int, out_node::Int)::Int
    key = (in_node, out_node)
    return get!(connection_innovations, key) do
        v = innovation_counter[]
        innovation_counter[] += 1
        return v
    end
end

"""
    reset_innovation_counter!()

Resets the counter (useful for tests).
"""
function reset_innovation_counter!()
    return innovation_counter[] = 3
end

end
