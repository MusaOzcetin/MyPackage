module Innovation

export next_innovation_number, reset_innovation_counter!, get_innovation_number

# Global innovation number tracker (starts at 3 because 1 & 2 are used initially)
# Store the highest innovation number and increment it each time you mutate or cross over
const innovation_counter = Ref(3)
const connection_innovations = Dict{Tuple{Int, Int}, Int}()

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
    if haskey(connection_innovations, key)
        return connection_innovations[key]
    else
        val = innovation_counter[]
        innovation_counter[] += 1
        connection_innovations[key] = val
        return val
    end
end

"""
TODO: remove this?
    next_innovation_number() → Int

Returns the next global innovation number.
"""
function next_innovation_number()::Int
    val = innovation_counter[]
    innovation_counter[] += 1
    return val
end

"""
    reset_innovation_counter!()

Resets the counter (useful for tests).
"""
function reset_innovation_counter!()
    innovation_counter[] = 3
end

end
