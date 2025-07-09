# Neat
NEAT (NeuroEvolution of Augmenting Topologies) is an evolutionary algorithm that simultaneously evolves both the topology and the weights of neural networks. Unlike traditional neural network training, which only adjusts weights, NEAT starts with simple networks without hidden nodes and gradually complexifies the network by adding nodes and connections through mutation. NEAT selects and breeds networks based on their fitness on the task, evolving increasingly complex and better-performing solutions over generations.

# Neat.jl

A minimal starting point for a NEAT implementation in Julia.

## Overview

This package defines the building blocks of the NEAT algorithm:

- **Types**

  - `Node` – represents an input, hidden, or output neuron
  - `Connection` – represents a directed, weighted edge with an innovation number
  - `Genome` – collection of nodes and connections

- **CreateGenome**

  - `create_genome(num_inputs, num_outputs)`
  - Builds a new genome with `num_inputs` input nodes, `num_outputs` output nodes, and two initial random connections from inputs → first output.
 
- **Population**
  - `initialize_population(num_genomes, num_inputs, num_outputs)`
  - Creates a population of `num_genomes` genomes, each with `num_inputs` input nodes and `num_outputs` output nodes. All genomes start with fully connected input-to-output links but no hidden nodes.

- **ForwardPass**

  - `forward_pass(genome, input_vector)`
  - Computes the network’s output (sigmoid activation) by summing enabled weighted connections from inputs → output.
 
- **Crosover**
  - `crossover(parent1, parent2)`
  - Takes two genomes, treats the fitter as the primary parent, and produces a child genome by inheriting genes from both parents according to NEAT’s crossover rules.
 
- **Mutation**
  - `mutate(genome)`
  - Applies all mutation operators probabilistically, such as `mutate_weights`, `add_connection` and `add_node`.

- **Speciation**
  - `assign_species!(population, species_list; threshold)`
  - Clusters genomes into species by comparing to species representatives with a compatibility threshold. In a next step, fitness, offspring counts and elites are re-computed.
  
- **Fitness**
  - `evaluate_fitness(genome)`
  - Tests the genome on the XOR problem, returning the negative sum of squared errors (higher is better).
    
- **Innovation**
  - `get_innovation_number(in_node, out_node)`
  - Returns the innovation number for a connection from `in_node` to `out_node`. If this connection is new, it assigns a new unique number. Otherwise, it returns the previously assigned number.
 
- **Visualizer**
  - Provides functions to visualize the evolutionary progress and internal structure of genomes in NEAT. It includes plotting fitness distributions, genome complexity, individual genome architectures, and animating genome evolution over generations.

## Getting Started

📘 [Getting Started Guide](docs/getting_started.md)

## Documentation

For full documentation, please visit the [Neat.jl Documentation](https://musaozcetin.github.io/Neat.jl/dev/).



[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://MusaOzcetin.github.io/Neat.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://MusaOzcetin.github.io/Neat.jl/dev/)
[![Build Status](https://github.com/MusaOzcetin/Neat.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/MusaOzcetin/Neat.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/MusaOzcetin/Neat.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/MusaOzcetin/Neat.jl)
```
