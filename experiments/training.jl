using Pkg
Pkg.activate("../")

using Neat: initialize_population, evaluate_fitness, mutate, crossover, forward_pass
using Neat.Types: Genome
using Neat.Speciation: assign_species!, select_elites, adjust_fitness!, compute_offspring_counts
using Random
using Statistics

function train(;
    pop_size=150,
    n_generations=100,
    input_size=2,
    output_size=1,
    speciation_threshold=0.3,
    elite_frac=0.6,
)
    population = initialize_population(pop_size, input_size, output_size)

    for generation in 1:n_generations
        for genome in population
            genome.fitness = evaluate_fitness(genome)
        end

        species_list = Vector{Vector{Genome}}()
        assign_species!(population, species_list; threshold=speciation_threshold)
        adjust_fitness!(species_list)
        offspring_counts = compute_offspring_counts(species_list, pop_size)

        new_population = Genome[]
        for (species, count) in zip(species_list, offspring_counts)
            if isempty(species)
                continue
            end

            elites = select_elites(species, elite_frac)
            mating_pool = length(elites) >= 2 ? elites : species

            for _ in 1:count
                parent1, parent2 = rand(mating_pool, 2)
                child = crossover(parent1, parent2)
                mutate(child)
                push!(new_population, child)
            end
        end

        population = new_population
    end

    for genome in population
        genome.fitness = evaluate_fitness(genome)
    end

    return population
end

final_pop = train(; pop_size=10, n_generations=10, speciation_threshold=3.0)

println("✅ Training complete!")

idx = argmax(g -> g.fitness, final_pop)
#best = final_pop[idx]
best = argmax(g -> g.fitness, final_pop)  
println("🏆 Best fitness: ", best.fitness)

# Optional XOR Test
xor_inputs = [[0.0, 0.0], [0.0, 1.0], [1.0, 0.0], [1.0, 1.0]]
xor_outputs = [0.0, 1.0, 1.0, 0.0]

for (x, y) in zip(xor_inputs, xor_outputs)
    prediction = forward_pass(best, x)[1]
    println("Input: ", x, " => Predicted: ", round(prediction, digits=2), " | Expected: ", y)
end
