export initialize_population

"""
    initialize_population(num_genomes::Int, num_inputs::Int, num_outputs::Int) → Vector{Genome}

Create a population of `n` genomes initialized with given number of input/output nodes.
Each genome is assigned a unique ID.

# Arguments
- `num_genomes`: Number of genomes to create.
- `num_inputs`: Number of input nodes.
- `num_outputs`: Number of output nodes.

# Returns
- A vector of `Genome` objects.
"""
function initialize_population(n::Int, num_inputs::Int, num_outputs::Int)
    population = Vector{Genome}(undef, n)
    for i in 1:n
        population[i] = create_genome(num_inputs, num_outputs)
    end
    return population
end


