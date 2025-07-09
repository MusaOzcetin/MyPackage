module Visualizer

using Plots
using Statistics
using StatsPlots
using GraphRecipes
using ..Types  # Adjust path as needed to import your Types module

export plot_genome_complexity, 
       plot_genome_network,
       animate_species_network_evolution,
       select_best_genomes


"""
    select_best_genomes(species_genomes_per_gen::Vector{Vector{T}}) where T

Selects and returns the genome with the highest fitness from each generation.

# Arguments
- `species_genomes_per_gen::Vector{Vector{T}}`: 
    A vector where each element contains the population of genomes (`Vector{T}`) for a generation.

# Returns
- `Vector{T}`: 
    A vector containing the best (highest fitness) genome from each generation.
"""
function select_best_genomes(species_genomes_per_gen::Vector{Vector{T}}) where T
    best_genomes = Vector{T}(undef, length(species_genomes_per_gen))
    for (i, genomes) in enumerate(species_genomes_per_gen)
        fitnesses = [g.fitness for g in genomes]
        max_idx = findmax(fitnesses)[2]
        best_genomes[i] = genomes[max_idx]
    end
    return best_genomes
end

"""
    plot_genome_complexity(genome_stats::Vector{Vector{Tuple{Int, Int}}})

Plots the average number of nodes and connections per generation to visualize genome complexity over time.

# Arguments
- `genome_stats::Vector{Vector{Tuple{Int, Int}}}`: 
    A vector where each element represents a generation, containing a vector of tuples. Each tuple contains the number of nodes and number of connections for a genome in that generation.

# Returns
- A `Plots.Plot` object displaying the evolution of average genome complexity (nodes and connections) across generations.
"""
function plot_genome_complexity(genome_stats::Vector{Vector{Tuple{Int, Int}}})
    gens = length(genome_stats)
    avg_nodes = [mean(first, stats) for stats in genome_stats]
    avg_conns = [mean(last,  stats) for stats in genome_stats]
    plot(1:gens, avg_nodes, label="Avg. Nodes", lw=2)
    plot!(1:gens, avg_conns, label="Avg. Connections", lw=2)
    xlabel!("Generation")
    ylabel!("Count")
    title!("Genome Complexity Over Time")
end

"""
    plot_genome_network(genome::Genome)

Visualizes the structure of a neural network genome as a directed graph.

# Arguments
- `genome::Genome`: A genome object containing nodes and connections, where each node has a type (`:input`, `:hidden`, or `:output`) and each connection has input/output nodes and a weight.

# Behavior
- Nodes are colored by type: green for input, blue for hidden, and red for output.
- Edge thickness is scaled by absolute connection weight.
- Only enabled connections between existing nodes are shown.
- If the genome has no valid nodes or connections, a warning plot is shown.

# Returns
- A `Plots.Plot` object displaying the genome network graph.
"""
function plot_genome_network(genome::Genome)
    nodes = genome.nodes
    conns = genome.connections
    valid_edges = [(c.in_node, c.out_node, abs(c.weight)) for c in values(conns)
                   if c.enabled && haskey(nodes, c.in_node) && haskey(nodes, c.out_node)]
    isempty(valid_edges) && return plot(title="⚠️ Empty or invalid genome")
    # layout groups
    xmap = Dict(:input=>1.0, :hidden=>2.0, :output=>3.0)
    groups = Dict(:input=>Int[], :hidden=>Int[], :output=>Int[])
    for (id,node) in nodes
        push!(groups[node.nodetype], id)
    end
    # positions
    positions = Dict{Int,Tuple{Float64,Float64}}()
    for (typ, ids) in groups
        sorted_ids = sort(ids)
        n = length(sorted_ids)
        ys = n==1 ? [0.5] : collect(range(0, stop=1, length=n))
        for (i,id) in enumerate(sorted_ids)
            positions[id] = (xmap[typ], ys[i])
        end
    end
    node_ids = sort(collect(keys(positions)))
    id2idx = Dict(id=>i for (i,id) in enumerate(node_ids))
    xs = [positions[id][1] for id in node_ids]
    ys = [positions[id][2] for id in node_ids]
    colors = [nodes[id].nodetype==:input ? :green : nodes[id].nodetype==:output ? :red : :blue for id in node_ids]
    # edges
    src=Int[]; dst=Int[]; ws=Float64[]
    for (i,j,w) in valid_edges
        if haskey(id2idx,i) && haskey(id2idx,j)
            push!(src, id2idx[i]); push!(dst, id2idx[j]); push!(ws, w)
        end
    end
    isempty(src) && return plot(title="⚠️ No visible connections")
    maxw = maximum(ws); edgw = [0.5+4*(w/maxw) for w in ws]
    graphplot(
        src,dst;
        x=xs, y=ys,
        names=string.(node_ids),
        nodefillc=colors,nodeshape=:circle,nodesize=0.2,
        nodestrokec=:black,nodestrokew=0.5,
        edgestrokec=:darkgray, edgestrokew=edgw,
        arrow=:closed, arrowsize=3,
        legend=false, title="Species Network Evolution"
    )
end

"""
    animate_species_network_evolution(species_genomes::Vector{Genome}, filepath::String = "species_network_evolution.gif")

Generates and saves an animation showing the evolution of the best genome network in each generation.

# Arguments
- `species_genomes::Vector{Genome}`: Vector containing the best genome from each generation.
- `filepath::String="species_network_evolution.gif"`: Path to save the resulting GIF file.

# Behavior
- Plots the neural network structure of the best genome from each generation.
- If a genome cannot be plotted (e.g., empty or invalid), a warning is issued and a placeholder frame is shown for that generation.
- Each frame is labeled with its generation index.
- The animation is saved as a GIF with a playback speed of 5 frames per second.
"""
function animate_species_network_evolution(species_genomes::Vector{Genome}, filepath::String="species_network_evolution.gif")
    anim = @animate for (i, genome) in enumerate(species_genomes)
        # Safely attempt plotting each generation
        p = try
            plot_genome_network(genome)
# Skips any generation whose best genome is “empty” (no edges).
        catch err
            @warn "Skipping Gen $i due to plotting error: $err"
            plot(title="⚠️ Skipped Gen $i")
        end
        title!(p, "Species Evolution – Generation $i")
        display(p)
    end
    # Save animation at higher speed
    gif(anim, filepath, fps=5)
end

end