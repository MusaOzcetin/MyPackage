module Visualizer

using Plots
using Statistics
using StatsPlots
using GraphRecipes

export plot_genome_complexity,
       plot_fitness_boxplot, 
       plot_genome_network,
       animate_species_network_evolution,
       select_best_genomes,
       get_lineage  # export lineage function

# Select best genome per generation by fitness (no `by` keyword)
function select_best_genomes(species_genomes_per_gen)
    best_genomes = Vector{typeof(species_genomes_per_gen[1][1])}(undef, length(species_genomes_per_gen))
    for (i, genomes) in enumerate(species_genomes_per_gen)
        fitnesses = [g.fitness for g in genomes]
        max_idx = findmax(fitnesses)[2]  # findmax returns (max_value, index)
        best_genomes[i] = genomes[max_idx]
    end
    return best_genomes
end

# Plot average genome complexity over generations
function plot_genome_complexity(genome_stats::Vector{Vector{Tuple{Int, Int}}})
    generations = length(genome_stats)
    avg_nodes = [mean(t -> t[1], gen) for gen in genome_stats]
    avg_conns = [mean(t -> t[2], gen) for gen in genome_stats]

    plot(1:generations, avg_nodes, label="Avg. Nodes", lw=2)
    plot!(1:generations, avg_conns, label="Avg. Connections", lw=2)
    xlabel!("Generation")
    ylabel!("Count")
    title!("Genome Complexity Over Time")
end

# Fitness boxplot per generation
function plot_fitness_boxplot(fitness_data::Vector{Vector{Float64}})
    filtered = [(i, gen) for (i, gen) in enumerate(fitness_data) if !isempty(gen)]
    isempty(filtered) && error("Cannot plot boxplot: All fitness generations are empty.")

    values = Float64[]
    groups = Int[]
    for (i, gen) in filtered
        append!(values, gen)
        append!(groups, fill(i, length(gen)))
    end

    boxplot(groups, values;
        xlabel = "Generation",
        ylabel = "Fitness",
        title = "Fitness Distribution per Generation",
        color = :lightblue,
        legend = false,
        xticks = (1:maximum(groups), ["Gen $i" for i in 1:maximum(groups)]))
end

# Plot single genome neural network graph
function plot_genome_network(genome)
    nodes = genome.nodes
    conns = genome.connections

    edges = [(c.in_node, c.out_node) for c in values(conns) if c.enabled]
    weights = [abs(c.weight) for c in values(conns) if c.enabled]

    isempty(edges) && return plot(title="Empty Network")

    node_ids = collect(keys(nodes))
    node_types = [nodes[id].type for id in node_ids]

    color_map = Dict(:input => :green, :hidden => :blue, :output => :red)
    node_colors = [color_map[t] for t in node_types]

    x_pos = Dict(:input => 1, :hidden => 2, :output => 3)

    function y_positions(ids)
        n = length(ids)
        n == 1 ? [0.5] : range(0, stop=1, length=n)
    end

    positions = Dict{Int, Tuple{Float64, Float64}}()
    for t in [:input, :hidden, :output]
        ids_t = filter(id -> nodes[id].type == t, node_ids)
        ys = collect(y_positions(ids_t))
        for (i, id) in enumerate(ids_t)
            positions[id] = (x_pos[t], ys[i])
        end
    end

    src = [e[1] for e in edges]
    dst = [e[2] for e in edges]

    max_w = maximum(weights)
    line_widths = 0.5 .+ 4 .* (weights ./ max_w)

    xs = [positions[id][1] for id in node_ids]
    ys = [positions[id][2] for id in node_ids]

    graphplot(src, dst;
        names = string.(node_ids),
        nodefillc = node_colors,
        nodeshape = :circle,
        nodestrokec = :black,
        nodesize = 0.15,
        # Avoid edge labels & widths due to reshape issues:
        # edgelabel = round.(weights, digits=2),
        # edgestrokew = line_widths,
        x = xs,
        y = ys,
        arrow = :closed,
        arrowsize = 4,
        title = "Genome Neural Network",
        legend = false,
        dpi = 150)
end

# Animate sequence of genomes (e.g. lineage)
function animate_species_network_evolution(species_genomes::Vector, filepath::String = "species_network_evolution.gif")
    anim = @animate for (gen_idx, genome) in enumerate(species_genomes)
        p = plot_genome_network(genome)
        title!(p, "Species Network Evolution - Generation $gen_idx")
        display(p)
    end
    gif(anim, filepath, fps=1)
end

# Follow lineage of genomes by parent-child relationship
function get_lineage(species_genomes_per_gen::Vector{Vector}, start_id::Int)
    lineage = Vector{typeof(species_genomes_per_gen[1][1])}()
    current_id = start_id

    for gen_index in 1:length(species_genomes_per_gen)
        gen = species_genomes_per_gen[gen_index]

        genome = findfirst(g -> g.id == current_id, gen)
        genome === nothing && break

        push!(lineage, genome)

        if gen_index == length(species_genomes_per_gen)
            break
        end

        next_gen = species_genomes_per_gen[gen_index + 1]
        child = findfirst(g -> getfield(g, :parent_id, 0) == current_id, next_gen)
        child === nothing && break
        current_id = child.id
    end

    return lineage
end

end # module
