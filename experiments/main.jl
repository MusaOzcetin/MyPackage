# experiments/main.jl

using Pkg
Pkg.activate("../")

import Neat: create_genome, evaluate_fitness, initialize_population, mutate

# Test create_genome
println("=== Test create_genome ===")
genome = create_genome(2, 1)

println("Genome ID: ", genome.id)
println("Number of Nodes: ", length(genome.nodes))
println("Number of Connections: ", length(genome.connections))

# Test evaluate_fitness
println("\n=== Test evaluate_fitness ===")
fitness_before = evaluate_fitness(genome)
genome.fitness = fitness_before
println("Fitness before mutation: ", round(fitness_before, digits=4))


# Test mutate
println("\n=== Test mutate ===")
println("Before mutation:")
println("  Nodes: $(length(genome.nodes)), Connections: $(length(genome.connections))")

mutate(genome)

println("After mutation:")
println("  Nodes: $(length(genome.nodes)), Connections: $(length(genome.connections))")

fitness_after = evaluate_fitness(genome)
genome.fitness = fitness_after
println("Fitness after mutation: ", round(fitness_after, digits=4))

# Test initialize_population
println("\n=== Test initialize_population ===")
population = initialize_population(3, 2, 1)
println("Population size: ", length(population))

for (i, g) in enumerate(population)
    pop_fitness = evaluate_fitness(g)
    println("Genome $i: ID=$(g.id), Nodes=$(length(g.nodes)), Connections=$(length(g.connections)), Fitness=$(round(pop_fitness, digits=4))")
end

