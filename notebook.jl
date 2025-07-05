### A Pluto.jl notebook ###
# v0.20.13

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    #! format: off
    return quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
    #! format: on
end

# ╔═╡ aaacb7be-33d0-4c89-ae75-5a43a1bfe9da
### A Pluto.jl notebook ###
# XOR_NEAT_Pluto.jl

begin
    import Pkg

    # Make sure required packages are available
    Pkg.add("GraphRecipes")

    # Activate the local Neat.jl project environment (adjust this path as needed!)
    Pkg.activate("C:/Users/vajda/OneDrive/Desktop/Neat.jl")

    # Load packages
    using PlutoUI, Plots, GraphRecipes

    # Import functionality from your local Neat module
    import Neat: create_genome, evaluate_fitness, initialize_population, mutate, forward_pass
end

# ╔═╡ 4810c522-a1fe-4fdf-893c-5e7eb4cca584
using Graphs

# ╔═╡ dcadfbf7-e3c9-40d4-abf4-7b392a81ccee
md"""
# 🧠 NEAT Solving the XOR Problem

This interactive Pluto notebook demonstrates how NEAT (NeuroEvolution of Augmenting Topologies) evolves neural networks to solve the classic XOR problem.

You can control population size and number of generations, and see how the best genome performs on the XOR inputs.
"""

### XOR Dataset

# ╔═╡ 0a149b9b-abd0-471b-b4d8-24d426951701
xor_inputs = [[0.0, 0.0], [0.0, 1.0], [1.0, 0.0], [1.0, 1.0]]

# ╔═╡ 3820e66e-1f35-4e79-8957-3e49b80c696d
xor_outputs = [0.0, 1.0, 1.0, 0.0]

# ╔═╡ 8acd2e2a-9d38-4f33-b9f7-22d5c045ddce
md"""### 🧪 XOR Dataset"""

# ╔═╡ bbebff3c-482c-4bc0-9c24-83bd57babc3b
hcat(xor_inputs, xor_outputs)

### Interactive Population Initialization

# ╔═╡ 00e33db8-d9b2-4ae6-966b-23071cc2a686
@bind population_size Slider(4:2:20, show_value=true)

# ╔═╡ e33341f6-df6e-4b0a-87b9-a20d269dff91
import Neat

# ╔═╡ 7ebcc93c-15f7-4f6b-8838-bee10ff8b74f
function plot_genome_topology(genome::Neat.Genome)
    nodes = collect(values(genome.nodes))
    conns = [c for c in values(genome.connections) if c.enabled]

    # Sort nodes by type for layout
    input_nodes  = filter(n -> n.nodetype == :input, nodes)
    bias_nodes   = filter(n -> n.nodetype == :bias, nodes)
    hidden_nodes = filter(n -> n.nodetype == :hidden, nodes)
    output_nodes = filter(n -> n.nodetype == :output, nodes)

    sorted_nodes = vcat(input_nodes, bias_nodes, hidden_nodes, output_nodes)
    node_ids = [n.id for n in sorted_nodes]
    labels = ["$(n.nodetype) $(n.id)" for n in sorted_nodes]

    # Build edge list for connections
    edges = [
        (findfirst(==(c.in_node), node_ids), findfirst(==(c.out_node), node_ids))
        for c in conns
    ]

   g = SimpleDiGraph(length(labels))
    for (src, dst) in edges
        add_edge!(g, src, dst)
    end

    graphplot(g; names=labels, method=:spring, curves=false, arrows=true, nodeshape=:circle)
end

# ╔═╡ cdd2e9c2-1555-45ca-a203-28694577f530
population = initialize_population(population_size, 2, 1)

# ╔═╡ 9cd847e2-d1de-49d3-bf87-f84883e63ce0
plot_genome_topology(population[1])

# ╔═╡ f352e426-82c1-47b8-b1e0-6166ab213f76
for g in population
    g.fitness = evaluate_fitness(g)
end

# ╔═╡ 365f4f6e-c1b6-4796-8747-2d6feb5ffbed
md"""### 🧬 Initial Population Created"""

# ╔═╡ c7eda833-e0ea-4927-954c-4db3972b5423
population

### Train Over Generations

# ╔═╡ 23a6a78c-777c-4583-b8c6-fe8d5c60d6e1
@bind generations Slider(1:200, show_value=true)

# ╔═╡ 1f60a448-31b9-4168-8002-750a7a958ee6
for i in 1:generations
    for g in population
        mutate(g)
        g.fitness = evaluate_fitness(g)
    end
end

# ╔═╡ 78fa6f2c-85a0-4583-b9f5-a3c1efcaf216
fitness_values = [g.fitness for g in population]

### 📈 Plot Fitness of Final Population

# ╔═╡ c89f5dd9-1840-4cf9-9b42-5f59121b3c85
plot(fitness_values, seriestype=:bar, title="Final Fitness per Genome", xlabel="Genome", ylabel="Fitness")

### 🏆 Best Genome Evaluation

# ╔═╡ 595ccb02-7787-4890-81bb-c8d5aa930b15
best = sort(population, by=g->g.fitness, rev=true)[1]

# ╔═╡ c2ccaaf5-11c6-411b-86f3-81e6008916fe
md"""### 🧪 Best Genome XOR Predictions"""

# ╔═╡ 4b9dbccb-fc8e-46ee-a153-82e294dfb257
for (x, y) in zip(xor_inputs, xor_outputs)
    prediction = forward_pass(best, x)[1]
    println("Input: ", x, " => Predicted: ", round(prediction, digits=2), " | Expected: ", y)
end

# ╔═╡ Cell order:
# ╠═aaacb7be-33d0-4c89-ae75-5a43a1bfe9da
# ╠═dcadfbf7-e3c9-40d4-abf4-7b392a81ccee
# ╠═0a149b9b-abd0-471b-b4d8-24d426951701
# ╠═3820e66e-1f35-4e79-8957-3e49b80c696d
# ╠═8acd2e2a-9d38-4f33-b9f7-22d5c045ddce
# ╠═bbebff3c-482c-4bc0-9c24-83bd57babc3b
# ╠═00e33db8-d9b2-4ae6-966b-23071cc2a686
# ╠═e33341f6-df6e-4b0a-87b9-a20d269dff91
# ╠═4810c522-a1fe-4fdf-893c-5e7eb4cca584
# ╠═7ebcc93c-15f7-4f6b-8838-bee10ff8b74f
# ╠═9cd847e2-d1de-49d3-bf87-f84883e63ce0
# ╠═cdd2e9c2-1555-45ca-a203-28694577f530
# ╠═f352e426-82c1-47b8-b1e0-6166ab213f76
# ╠═365f4f6e-c1b6-4796-8747-2d6feb5ffbed
# ╠═c7eda833-e0ea-4927-954c-4db3972b5423
# ╠═23a6a78c-777c-4583-b8c6-fe8d5c60d6e1
# ╠═1f60a448-31b9-4168-8002-750a7a958ee6
# ╠═78fa6f2c-85a0-4583-b9f5-a3c1efcaf216
# ╠═c89f5dd9-1840-4cf9-9b42-5f59121b3c85
# ╠═595ccb02-7787-4890-81bb-c8d5aa930b15
# ╠═c2ccaaf5-11c6-411b-86f3-81e6008916fe
# ╠═4b9dbccb-fc8e-46ee-a153-82e294dfb257
