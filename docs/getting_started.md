# Getting Started with Neat.jl

Welcome to **Neat.jl** – a Julia implementation of the NEAT (NeuroEvolution of Augmenting Topologies) algorithm.

This guide will walk you through setting up and running your first experiment using Neat.jl.

---

## Requirements

- Julia 1.8 or newer (recommended: Julia 1.11+)
- Git (for cloning the repo)
- VS Code or any Julia-compatible editor (optional)

---

## Installation

## 1. Clone the repository

```bash
git clone https://github.com/your-username/Neat.jl.git
cd Neat.jl
```
## 2. Basic Working Example
```julia
using Neat  
```
### 1. Create a new genome with 2 input nodes and 1 output node
```julia
genome = create_genome(2, 1)
println("Created genome with ID: ", genome.id)
println("Number of nodes: ", length(genome.nodes))
println("Number of connections: ", length(genome.connections))
```
### 2. Evaluate the genome's fitness
```julia
fitness_before = evaluate_fitness(genome)
genome.fitness = fitness_before
println("Fitness before mutation: ", round(fitness_before, digits=4))
```
### 3. Mutate the genome 
```julia
mutate(genome)

println("After mutation:")
println("Number of nodes: ", length(genome.nodes))
println("Number of connections: ", length(genome.connections))
```
### 4. Re-evaluate fitness after mutation
```julia
fitness_after = evaluate_fitness(genome)
genome.fitness = fitness_after
println("Fitness after mutation: ", round(fitness_after, digits=4))
```
### 5. Simple evolutionary loop example: initialize a population, evaluate, mutate
```julia
population = [create_genome(2, 1) for _ in 1:10]

for generation in 1:10
    println("\nGeneration $generation")
    # Evaluate fitness
    for g in population
        g.fitness = evaluate_fitness(g)
    end

    # Print best fitness this generation
    fitnesses = [g.fitness for g in population]
    println("Best fitness: ", round(maximum(fitnesses), digits=4))

    # Mutate all genomes for next generation
    for g in population
        mutate(g)
    end
end
```
## 3. Enhancements
- number of species and number of genomes per species
- mutation regarding either the weights, nodes or connections
- crossover process instead of mutation process

