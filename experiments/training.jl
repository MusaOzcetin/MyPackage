using Pkg
Pkg.activate("../")

using Neat
using Random
using Statistics
using Plots

"""
    adjust_threshold!(threshold::Ref{Float64}, species_list::Vector{Vector{Genome}};
                      target_species=10, adjust_rate=0.1)

Modifies the speciation threshold based on the number of species in `species_list`.
If the number of species exceeds `target_species`, the threshold is increased by `adjust_rate`.
If it is below `target_species`, the threshold is decreased by `adjust_rate`, but not below 0.1.
This helps maintain a stable number of species during evolution.
"""
function adjust_threshold!(
    threshold::Ref{Float64},
    species_list::Vector{Vector{Genome}};
    target_species=10,
    adjust_rate=0.1,
)
    n_species = length(species_list)

    if n_species > target_species
        threshold[] += adjust_rate
    elseif n_species < target_species
        threshold[] -= adjust_rate
        threshold[] = max(threshold[], 0.1)
    end
end

"""
    train(; pop_size=150, n_generations=100, input_size=2, output_size=1, speciation_threshold=0.3)

Run a full NEAT training loop for the specified number of generations.

# Keyword Arguments
- `pop_size`: Number of genomes in the population
- `n_generations`: Number of generations to evolve
- `input_size`: Number of input nodes per genome
- `output_size`: Number of output nodes per genome
- `speciation_threshold`: Compatibility threshold for species assignment

# Returns
- The final evolved population
"""
function train(;
    pop_size=150, n_generations=100, input_size=2, output_size=1, speciation_threshold=3.0
)
    threshold = Ref(speciation_threshold)
    population = initialize_population(pop_size, input_size, output_size)

    # Best-tracking Variablen
    best_history = Float64[]
    best_generation = 0
    global_best_fitness = -Inf
    global_best_genome = nothing
    best_per_generation = Genome[]

    for generation in 1:n_generations
        println("\n=== Generation $generation ===")

        for genome in population
            genome.fitness = evaluate_fitness(genome)
        end

        best_in_gen = argmax(g -> g.fitness, population)
        push!(best_per_generation, deepcopy(best_in_gen))

        # Best-Tracking
        current_best_idx = argmax(g -> g.fitness, population)
        current_best = current_best_idx
        push!(best_history, current_best.fitness)

        if current_best.fitness > global_best_fitness
            global_best_fitness = current_best.fitness
            global_best_genome = deepcopy(current_best)
            best_generation = generation
        end

        # Speciation
        species_list = Vector{Vector{Genome}}()
        assign_species!(population, species_list; threshold=threshold[])

        adjust_threshold!(threshold, species_list; target_species=10, adjust_rate=0.2)

        for (i, species) in enumerate(species_list)
            avg_fit = mean(g -> g.fitness, species)
            println(
                "Species $i: $(length(species)) genomes, average fitness $(round(avg_fit, digits=4))",
            )
        end

        adjust_fitness!(species_list)

        offspring_counts = compute_offspring_counts(species_list, pop_size)

        for i in eachindex(offspring_counts)
            offspring_counts[i] = max(offspring_counts[i], 2)
        end

        println("Offspring counts: $offspring_counts")

        new_population = Genome[]
        for (species, count) in zip(species_list, offspring_counts)
            if isempty(species)
                continue
            end

            elites = select_elites(species, min(1, length(species)))
            append!(new_population, elites)

            remaining = count - length(elites)
            if remaining > 0
                if length(species) > length(elites)
                    parents = select_parents(species, remaining; exclude=Set(elites))
                    for (parent1, parent2) in parents
                        child = crossover(parent1, parent2)
                        if child === nothing
                            fallback = deepcopy(parent1)
                            mutate(fallback)
                            push!(new_population, fallback)
                        else
                            mutate(child)
                            push!(new_population, child)
                        end
                    end
                else
                    for _ in 1:remaining
                        clone = deepcopy(elites[1])
                        mutate(clone)
                        push!(new_population, clone)
                    end
                end
            end
        end

        population = new_population
    end # generation loop

    println("\n=== Training done ===")
    println("Best genome appeared in generation $best_generation")

    for genome in population
        genome.fitness = evaluate_fitness(genome)
    end

    global_best_genome_id = global_best_genome !== nothing ? global_best_genome.id : -1
    println("Best genome ID: $global_best_genome_id")

    return population, best_per_generation
end

final_pop, best_per_generation = train(;
    pop_size=100, n_generations=2000, speciation_threshold=1.0
)

println("Doooooooonnnnneeeeee")

idx = argmax(g -> g.fitness, final_pop)
best = idx
println("Best fitness in final population: ", best.fitness)

fitnesses = [g.fitness for g in best_per_generation]
plot(
    1:length(fitnesses),
    fitnesses;
    xlabel="Generation",
    ylabel="Best Fitness",
    title="Best Fitness per Generation",
    legend=false,
)
