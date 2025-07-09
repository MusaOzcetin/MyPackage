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

Clone the repository and activate the environment.

```bash
git clone https://github.com/your-username/Neat.jl.git
cd Neat.jl
```

## 2. Basic Working Example

Creating, evaluating, mutating, and evolving genomes.

### 2.1. Create a minimal genome

Creating a genome with 2 input and 1 output node.

```julia
using Neat

genome = create_genome(2, 1)
println("Created genome with ID: ", genome.id)
println("Number of nodes: ", length(genome.nodes))
println("Number of connections: ", length(genome.connections))
```

### 2.2. Evaluate fitness

Evaluate the genome on a simple XOR task using evaluate_fitness.

```julia
fitness_before = evaluate_fitness(genome)
genome.fitness = fitness_before
println("Fitness before mutation: ", round(fitness_before, digits=4))
```

### 2.3. Mutate the genome

Apply random structural and weight mutations to the genome.

```julia
mutate(genome)

println("After mutation:")
println("Number of nodes: ", length(genome.nodes))
println("Number of connections: ", length(genome.connections))
```

### 2.4. Re-evaluate fitness after mutation

Re-evaluate the modified genome to observe fitness change.

```julia
fitness_after = evaluate_fitness(genome)
genome.fitness = fitness_after
println("Fitness after mutation: ", round(fitness_after, digits=4))
```

### 2.5. Simulate simple evolution

Create a small population, evaluates fitness, and mutates over generations.

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

## 3. NEAT Features Supported

- Species tracking and reproduction using speciation.jl
- Mutation operators for weights, nodes, and connections
- Crossover-based reproduction instead of mutation-only
- Training over multiple generations with evolve_generation() or train()
