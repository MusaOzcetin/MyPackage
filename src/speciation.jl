module Speciation

using ..Types
using ..NeatConfig
using Random

export compatibility_distance
export assign_species!
export adjust_fitness!
export compute_offspring_counts


"""
    compatibility_distance(g1::Genome, g2::Genome;) → Float64

Compute the compatibility distance between two genomes `g1` and `g2` (similarity between genomes using innovation numbers and weights).
Uses NEAT's distance formula:

    δ = (c1 * E / N) + (c2 * D / N) + (c3 * W)

- E = number of excess genes
- D = number of disjoint genes
- W = average weight difference of matching genes
- N = number of genes in the larger genome (set to 1 if small for stability)

# Keyword Arguments
- `c1`, `c2`, `c3`: importance of each factor

# Returns
- A `Float64` distance value (lower means more similar)
"""
function compatibility_distance(g1::Genome, g2::Genome;)
    conf = get_config()
    m = m["speciation"]
    c1 = m["c1"]
    c2 = m["c2"]
    c3 = m["c3"]


    # Build lookup tables for connections in each genome
    conns1 = Dict(c.innovation_number => c for c in values(g1.connections))
    conns2 = Dict(c.innovation_number => c for c in values(g2.connections))

    # Collect innovation numbers from both genomes
    innovs1 = keys(conns1)
    innovs2 = keys(conns2)
    all_innovs = union(innovs1, innovs2)

    # Determine the highest innovation number in each genome
    max_innov1 = isempty(innovs1) ? 0 : maximum(innovs1)
    max_innov2 = isempty(innovs2) ? 0 : maximum(innovs2)
    max_innov = max(max_innov1, max_innov2)

    # Initialize distance components
    D = 0       # Disjoint gene count
    E = 0       # Excess gene count
    W = 0.0     # Sum of weight differences for matching genes
    M = 0       # Count of matching genes

    # Iterate through all innovation numbers seen in either genome
    for innov in all_innovs
        c1_conn = get(conns1, innov, nothing)
        c2_conn = get(conns2, innov, nothing)

        if c1_conn !== nothing && c2_conn !== nothing
            # Matching gene: both genomes have this innovation number
            W += abs(c1_conn.weight - c2_conn.weight)
            M += 1
        elseif innov <= max_innov1 && innov <= max_innov2
            # Disjoint gene: occurs within range of both genomes
            D += 1
        else
            # Excess gene: occurs beyond the range of one genome
            E += 1
        end
    end

    # Average weight difference for matching genes
    avg_weight_diff = M > 0 ? W / M : 0.0

    # Normalize by the size of the larger genome (or 1 if both are small)
    N = max(length(conns1), length(conns2))
    N = N < 20 ? 1 : N

    # NEAT compatibility distance formula
    return (c1 * E / N) + (c2 * D / N) + (c3 * avg_weight_diff)
end

"""
    assign_species!(population::Vector{Genome}, species_list::Vector{Vector{Genome}};
                    threshold=3.0)

Groups genomes into species based on compatibility.

Assign each genome in the population to a species in `species_list` based on
compatibility distance. A genome is added to the first species where distance
to the representative is below the threshold. This is greedy but also thoughtfully. We 
are comparing the dist of a genome with all of the representatives of a species and select the lowest. 
Still its not guaranteed that the representatives are good so thats something we might improve in the future. 

# Arguments
- `population`: Vector of genomes to classify
- `species_list`: Vector of species (each a vector of genomes)
- `threshold`: Maximum allowed compatibility distance to join a species

"""
function assign_species!(population::Vector{Genome}, species_list::Vector{Vector{Genome}}; threshold::Float64=3.0)
    empty!(species_list)
    shuffle!(population)

    reps = Genome[]  # current representatives

    for (i, g) in enumerate(population)

        if isempty(reps)
            # first genome -> new species
            push!(species_list, [g])
            push!(reps, g) # also push to representatives group
            continue
        end

        # compute distances to each representative
        dists = [compatibility_distance(g, reps[j]) for j in eachindex(reps)]
        

        # find best match index which is the minimum distance in this case
        idx = argmin(dists)

        # we found at least one dist which is smaller than the threshold so we assign
        if dists[idx] <= threshold
            push!(species_list[idx], g)
        else # we didnt find a fitting species so we create a new representative
            push!(species_list, [g])
            push!(reps, g)
        end
    end

end

"""
    adjust_fitness!(species_list::Vector{Vector{Genome}})

Applies fitness sharing to scale each genome’s fitness relative to its species size.

Modifies each genome's fitness value in-place by applying NEAT-style fitness sharing:
- Divides each genome's fitness by the number of members in its species.

# Arguments
- `species_list`: A vector of species, where each species is a vector of genomes.

# Side Effect
- Overwrites each genome's `fitness` value with the adjusted fitness.
"""
function adjust_fitness!(species_list::Vector{Vector{Genome}})
    for species in species_list
        s_size = length(species)
        for genome in species
            genome.adjusted_fitness = genome.fitness / s_size
        end
    end
end

"""
    compute_offspring_counts(species_list::Vector{Vector{Genome}}, population_size::Int) → Vector{Int}

Calculates how many offspring each species is allowed to produce based on the
sum of adjusted fitness values in each species, relative to the population's total.

# Arguments
- `species_list`: List of species (each is a list of genomes)
- `population_size`: Total number of offspring to allocate

# Returns
- `Vector{Int}`: A list of offspring counts per species (same order)
"""
function compute_offspring_counts(species_list::Vector{Vector{Genome}}, population_size::Int)::Vector{Int}
    # Use adjusted fitness instead of raw fitness
    species_fitness_totals = [sum(g.adjusted_fitness for g in s) for s in species_list]
    total_adjusted = sum(species_fitness_totals)

    if total_adjusted == 0
        # Avoid divide-by-zero: assign equal offspring
        return fill(div(population_size, length(species_list)), length(species_list))
    end

    # Proportionally allocate offspring
    counts = [
        round(Int, (fit / total_adjusted) * population_size)
        for fit in species_fitness_totals
    ]

    # Adjust rounding to make sure total exactly matches population_size
    diff = population_size - sum(counts)
    for i in 1:abs(diff)
        idx = mod1(i, length(counts))
        counts[idx] += sign(diff)
    end

    return counts
end


"""
    select_elites(species::Vector{T}, elite_frac::Float64) where {T}

Selects the top `elite_frac * 100`% of genomes from the given species based
on their `adjusted_fitness`.

# Arguments
- `species`: A vector of individuals with an `adjusted_fitness` field.
- `elite_frac`: Fraction of the species to retain as elites (e.g., 0.1 for 10%).

# Returns
- A vector of the top-performing genomes, sorted by descending `adjusted_fitness`.
"""
function select_elites(species::Vector{T}, elite_frac::Float64) where {T}
    # Compute how many elites to keep at least 2)
    num_elites = max(1, ceil(Int, elite_frac * length(species)))
    # Sort the species in descending 
    sorted = sort(species, by = g -> g.adjusted_fitness, rev = true)
    # Return the top num_elites genomes
    return sorted[1:num_elites]
end

export select_elites

end