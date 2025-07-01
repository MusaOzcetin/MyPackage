using Pkg
Pkg.activate("../")

using Neat
using Random
using Statistics

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
function train(; pop_size=150, n_generations=100, input_size=2, output_size=1, speciation_threshold=0.3)

    population = initialize_population(pop_size, input_size, output_size)

    for generation in 1:n_generations
        println("\n=== Generation $generation ===")

        for genome in population
            genome.fitness = evaluate_fitness(genome)
        end

        species_list = Vector{Vector{Genome}}()
        assign_species!(population, species_list; threshold=speciation_threshold)

        for (i, species) in enumerate(species_list)
            avg_fit = mean(g -> g.fitness, species)
            println("Species $i: $(length(species)) genomes, average fitness $(round(avg_fit, digits=4))")
        end

        adjust_fitness!(species_list)

        
        offspring_counts = compute_offspring_counts(species_list, pop_size)
        println("Offspring counts: $offspring_counts")

        
        new_population = Genome[]
        for (species, count) in zip(species_list, offspring_counts)
            if isempty(species)
                continue
            end

            
            best = species[argmax([g.fitness for g in species])]
            push!(new_population, best)

            # Fill remaining slots with crossover + mutation
            for _ in 2:count
                parent1 = rand(species)
                parent2 = rand(species)
                child = crossover(parent1, parent2)
                mutate(child)
                push!(new_population, child)
            end
        end

        
        population = new_population

    end # for each generation

    return population
end

final_pop = train(pop_size=100, n_generations=50)

println("Doooooooonnnnneeeeee")

idx = argmax(g -> g.fitness, final_pop)
best = idx
println("Best fitness: ", best.fitness)
