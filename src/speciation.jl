module Speciation

using ..Types
using Random

export compatibility_distance,
       assign_species!,
       adjust_fitness!,
       compute_offspring_counts,
       select_elites,
       select_parents

"""
    compatibility_distance(g1::Genome, g2::Genome; c1=1.0, c2=1.0, c3=3.0) → Float64

Compute NEAT-style compatibility distance between two genomes using:

    δ = (c1 * E / N) + (c2 * D / N) + (c3 * W)

# Terms
- E = excess genes
- D = disjoint genes
- W = average weight difference of matching genes
- N = number of genes in larger genome (set to 1 if small)

# Returns
- Distance ∈ ℝ, where lower = more similar
"""
function compatibility_distance(g1::Genome, g2::Genome; c1=1.0, c2=1.0, c3=3.0)
    conns1 = Dict(c.innovation_number => c for c in values(g1.connections))
    conns2 = Dict(c.innovation_number => c for c in values(g2.connections))

    innovs1 = keys(conns1)
    innovs2 = keys(conns2)
    all_innovs = union(innovs1, innovs2)

    max_innov1 = isempty(innovs1) ? 0 : maximum(innovs1)
    max_innov2 = isempty(innovs2) ? 0 : maximum(innovs2)

    D, E, W, M = 0, 0, 0.0, 0

    for innov in all_innovs
        c1_conn = get(conns1, innov, nothing)
        c2_conn = get(conns2, innov, nothing)

        if c1_conn !== nothing && c2_conn !== nothing
            W += abs(c1_conn.weight - c2_conn.weight)
            M += 1
        elseif innov <= max_innov1 && innov <= max_innov2
            D += 1
        else
            E += 1
        end
    end

    avg_weight_diff = M > 0 ? W / M : 0.0
    N = max(length(conns1), length(conns2))
    N = N < 20 ? 1 : N

    return (c1 * E / N) + (c2 * D / N) + (c3 * avg_weight_diff)
end

"""
    assign_species!(population, species_list; threshold=3.0)

Assigns each genome to a species based on compatibility distance.
Creates a new species if no suitable match is found.
"""
function assign_species!(population::Vector{Genome}, species_list::Vector{Vector{Genome}}; threshold::Float64=3.0)
    empty!(species_list)
    shuffle!(population)

    reps = Genome[]

    println("=== Starting species assignment (threshold = $threshold) ===")
    for (i, g) in enumerate(population)
        println("\n[Genome #$i ID=$(g.id)] Computing distances to reps:")
        if isempty(reps)
            println("  No reps yet -> create species #1 with rep ID=$(g.id)")
            push!(species_list, [g])
            push!(reps, g)
            continue
        end

        dists = [compatibility_distance(g, reps[j]) for j in eachindex(reps)]
        for j in eachindex(reps)
            println("    to Rep #$j (ID=$(reps[j].id)): distance = $(round(dists[j], digits=4))")
        end

        d_min = minimum(dists)
        d_mean = mean(dists)
        d_max = maximum(dists)

        println("  -> stats: min=$(round(d_min,4)), mean=$(round(d_mean,4)), max=$(round(d_max,4))")

        idx = argmin(dists)
        println("  -> best Rep #$idx ID=$(reps[idx].id) with distance=$(round(dists[idx],4))")

        if dists[idx] <= threshold
            println("     Assigning to existing species #$idx")
            push!(species_list[idx], g)
        else
            new_idx = length(species_list) + 1
            println("     Exceeds threshold -> creating new species #$new_idx with rep ID=$(g.id)")
            push!(species_list, [g])
            push!(reps, g)
        end
    end

    println("\n=== Final species summary ===")
    for (k, s) in enumerate(species_list)
        ids = [gem.id for gem in s]
        println("Species #$k (rep ID=$(reps[k].id)): $(length(s)) genomes -> IDs = $(ids)")
    end
end

"""
    adjust_fitness!(species_list)

Divides fitness by species size (fitness sharing).
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
    compute_offspring_counts(species_list, population_size)

Returns how many offspring each species gets based on adjusted fitness.
"""
function compute_offspring_counts(species_list::Vector{Vector{Genome}}, population_size::Int)::Vector{Int}
    species_fitness_totals = [sum(g.adjusted_fitness for g in s) for s in species_list]
    total_adjusted = sum(species_fitness_totals)

    if total_adjusted == 0
        return fill(div(population_size, length(species_list)), length(species_list))
    end

    counts = [
        round(Int, (fit / total_adjusted) * population_size)
        for fit in species_fitness_totals
    ]

    # Ensure total sums exactly to population size
    diff = population_size - sum(counts)
    for i in 1:abs(diff)
        idx = mod1(i, length(counts))
        counts[idx] += sign(diff)
    end

    return counts
end

"""
    select_elites(species::Vector{T}, num_elites::Int) where T

Selects the top-performing genomes based on adjusted fitness.
"""
function select_elites(species::Vector{T}, num_elites::Int) where {T}
    sorted = sort(species, by = g -> g.adjusted_fitness, rev = true)
    return sorted[1:min(num_elites, length(sorted))]
end

"""
    select_parents(species::Vector{T}, num_parents::Int; exclude::Set{T}=Set()) where T

Roulette wheel selection (fitness-proportionate) for reproduction.
"""
function select_parents(species::Vector{T}, num_parents::Int; exclude::Set{T}=Set()) where {T}
    candidates = filter(g -> !(g in exclude), species)
    total_fitness = sum(g.adjusted_fitness for g in candidates)

    if isempty(candidates) || total_fitness == 0
        return [(rand(candidates), rand(candidates)) for _ in 1:num_parents]
    end

    function roulette_select()
        r = rand() * total_fitness
        acc = 0.0
        for g in candidates
            acc += g.adjusted_fitness
            if acc >= r
                return g
            end
        end
        return last(candidates)
    end

    return [(roulette_select(), roulette_select()) for _ in 1:num_parents]
end

end # module