# Neat

# Neat.jl

A minimal starting point for a NEAT (NeuroEvolution of Augmenting Topologies) implementation in Julia.

## Overview

This package defines the basic building blocks of a NEAT genome:

- **Types**

  - `Node` – represents an input, hidden, or output neuron
  - `Connection` – represents a directed, weighted edge with an innovation number
  - `Genome` – collection of nodes and connections

- **CreateGenome**

  - `create_genome(id, num_inputs, num_outputs)`
  - Builds a new genome with `num_inputs` input nodes, `num_outputs` output nodes, and two initial random connections from inputs → first output.

- **ForwardPass**

  - `forward_pass(genome, input_vector)`
  - Computes the network’s output (sigmoid activation) by summing enabled weighted connections from inputs → output.

- **Fitness**
  - `evaluate_fitness(genome)`
  - Tests the genome on the XOR problem, returning the negative sum of squared errors (higher is better).

## Getting Started

📘 [Getting Started Guide](docs/getting_started.md)



[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://MusaOzcetin.github.io/Neat.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://MusaOzcetin.github.io/Neat.jl/dev/)
[![Build Status](https://github.com/MusaOzcetin/Neat.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/MusaOzcetin/Neat.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/MusaOzcetin/Neat.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/MusaOzcetin/Neat.jl)
```
