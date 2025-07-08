cd(@__DIR__)

include("../genome.jl")
using .Types

include("../innovation.jl")
using .Innovation

include("../mutation.jl")
using .Mutation

include("../create_genome.jl")
using .CreateGenome

include("../create_population.jl")
using .Population

include(joinpath(@__DIR__, "Visualizer.jl"))
using .Visualizer

using Statistics
using Plots


population = Neat.initialize_population(10, 2, 1)
num_generations = 20
species_genomes_per_gen = Vector{Vector{Neat.Genome}}(undef, num_generations)

for gen in 1:num_generations
    println("\nGeneration $gen")
    for genome in population
        genome.fitness = Neat.evaluate_fitness(genome)
    end
    species_genomes_per_gen[gen] = deepcopy(population)

    fitnesses = [g.fitness for g in population]
    println("  Best fitness: ", round(maximum(fitnesses), digits=4))
    println("  Avg fitness: ", round(mean(fitnesses), digits=4))

    for genome in population
        Neat.mutate(genome)
    end
end

fitness_data = [ [g.fitness for g in gen] for gen in species_genomes_per_gen ]
genome_stats = [ [(length(g.nodes), length(g.connections)) for g in gen] for gen in species_genomes_per_gen ]
best_genomes = Visualizer.select_best_genomes(species_genomes_per_gen)

p1 = Visualizer.plot_fitness_boxplot(fitness_data)
display(p1)  # shows fitness boxplot in its own window
savefig(p1, "fitness_boxplot.png")  # optionally save to file

p2 = Visualizer.plot_genome_complexity(genome_stats)
display(p2)  # shows genome complexity plot separately
savefig(p2, "genome_complexity.png")  # optionally save to file

Visualizer.animate_species_network_evolution(best_genomes, "best_species_evolution.gif")
println("Animation saved as best_species_evolution.gif")
