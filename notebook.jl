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

# ╔═╡ f00aa4e9-d298-44d5-802c-ce847baac72a
### A Pluto.jl notebook ###
# XOR_NEAT_Pluto.jl

begin
    using Pkg
    Pkg.activate(".")
    using PlutoUI, Plots
    import Neat: create_genome, evaluate_fitness, initialize_population, mutate, forward_pass
end

# ╔═╡ 6fc5fc46-f4c5-40d4-b749-1a1b89b52094
md"""
# 🧠 NEAT Solving the XOR Problem

This interactive Pluto notebook demonstrates how NEAT (NeuroEvolution of Augmenting Topologies) evolves neural networks to solve the classic XOR problem.

You can control population size and number of generations, and see how the best genome performs on the XOR inputs.
"""

### XOR Dataset

# ╔═╡ 901fb104-d648-4e93-b9bd-2f15780cb0f9
xor_inputs = [[0.0, 0.0], [0.0, 1.0], [1.0, 0.0], [1.0, 1.0]]

# ╔═╡ adaeb015-7920-4655-b572-39b6a76c5a40
xor_outputs = [0.0, 1.0, 1.0, 0.0]

# ╔═╡ 8799a7c4-2a24-4ef5-bdc2-daab54efd262
md"""### 🧪 XOR Dataset"""

# ╔═╡ d801e009-49ae-4436-b1c0-7c92e647a96f
hcat(xor_inputs, xor_outputs)

### Interactive Population Initialization

# ╔═╡ ae8fd2e5-67ec-46b8-95cb-28afc687abc4
@bind population_size Slider(4:2:20, show_value=true)

# ╔═╡ 12905922-5d01-4a10-857f-d48a9b2f2970
population = initialize_population(population_size, 2, 1)

# ╔═╡ 0c6bc5d4-39ec-49b8-ac8b-740da0d046ba
for g in population
    g.fitness = evaluate_fitness(g)
end

# ╔═╡ 77d0686d-f60c-481b-b97c-140ce6d31caa
md"""### 🧬 Initial Population Created"""

# ╔═╡ 9d115f84-8591-4b04-853b-1e62f6ecd10a
population

### Train Over Generations

# ╔═╡ 7a76af97-ea69-4077-bf43-9b879157d460
@bind generations Slider(1:200, show_value=true)

# ╔═╡ ea9b9108-fa94-4613-9f27-606bbf34ec52
for i in 1:generations
    for g in population
        mutate(g)
        g.fitness = evaluate_fitness(g)
    end
end

# ╔═╡ 3f52a1fe-c5c7-4476-a9ca-455d43a58176
fitness_values = [g.fitness for g in population]

### 📈 Plot Fitness of Final Population

# ╔═╡ 2796d116-4e87-437f-a8b9-465cbe61846c
plot(fitness_values, seriestype=:bar, title="Final Fitness per Genome", xlabel="Genome", ylabel="Fitness")

### 🏆 Best Genome Evaluation

# ╔═╡ a0fe9bab-358d-4258-9851-57e0b902cdda
best = sort(population, by=g->g.fitness, rev=true)[1]

# ╔═╡ 25b9d984-b7ae-4637-a930-a1885ac32c71
md"""### 🧪 Best Genome XOR Predictions"""

# ╔═╡ 1b429d21-7300-4ee1-a6b1-d38d93c72b1c
for (x, y) in zip(xor_inputs, xor_outputs)
    prediction = forward_pass(best, x)[1]
    println("Input: ", x, " => Predicted: ", round(prediction, digits=2), " | Expected: ", y)
end

# ╔═╡ Cell order:
# ╠═f00aa4e9-d298-44d5-802c-ce847baac72a
# ╠═6fc5fc46-f4c5-40d4-b749-1a1b89b52094
# ╠═901fb104-d648-4e93-b9bd-2f15780cb0f9
# ╠═adaeb015-7920-4655-b572-39b6a76c5a40
# ╠═8799a7c4-2a24-4ef5-bdc2-daab54efd262
# ╠═d801e009-49ae-4436-b1c0-7c92e647a96f
# ╠═ae8fd2e5-67ec-46b8-95cb-28afc687abc4
# ╠═12905922-5d01-4a10-857f-d48a9b2f2970
# ╠═0c6bc5d4-39ec-49b8-ac8b-740da0d046ba
# ╠═77d0686d-f60c-481b-b97c-140ce6d31caa
# ╠═9d115f84-8591-4b04-853b-1e62f6ecd10a
# ╠═7a76af97-ea69-4077-bf43-9b879157d460
# ╠═ea9b9108-fa94-4613-9f27-606bbf34ec52
# ╠═3f52a1fe-c5c7-4476-a9ca-455d43a58176
# ╠═2796d116-4e87-437f-a8b9-465cbe61846c
# ╠═a0fe9bab-358d-4258-9851-57e0b902cdda
# ╠═25b9d984-b7ae-4637-a930-a1885ac32c71
# ╠═1b429d21-7300-4ee1-a6b1-d38d93c72b1c
