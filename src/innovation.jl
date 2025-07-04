module Innovation

export next_innovation_number, reset_innovation_counter!

# Global innovation number tracker (starts at 3 because 1 & 2 are used initially)
# Store the highest innovation number and increment it each time you mutate or cross over
const innovation_counter = Ref(3)

"""
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
    return innovation_counter[] = 3
end

end
