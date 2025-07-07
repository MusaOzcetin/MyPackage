using Plots
include("Visualizer.jl")
using .Visualizer

# Dummy genome structs with id and parent_id for lineage tracking
struct DummyNode
    id::Int
    type::Symbol
end

struct DummyConnection
    in_node::Int
    out_node::Int
    weight::Float64
    enabled::Bool
end

struct DummyGenome
    id::Int               # Unique genome ID
    parent_id::Int        # Parent genome ID, 0 if none
    nodes::Dict{Int, DummyNode}
    connections::Dict{Tuple{Int, Int}, DummyConnection}
    fitness::Float64      # Fitness for selection
end

function create_dummy_genome(id, parent_id, num_inputs, num_hidden, num_outputs)
    nodes = Dict{Int, DummyNode}()
    connections = Dict{Tuple{Int, Int}, DummyConnection}()

    node_id = 1
    for _ in 1:num_inputs
        nodes[node_id] = DummyNode(node_id, :input)
        node_id += 1
    end
    for _ in 1:num_hidden
        nodes[node_id] = DummyNode(node_id, :hidden)
        node_id += 1
    end
    for _ in 1:num_outputs
        nodes[node_id] = DummyNode(node_id, :output)
        node_id += 1
    end

    # Fully connect input and hidden nodes to outputs
    for (in_id, node) in nodes
        if node.type != :output
            for (out_id, out_node) in nodes
                if out_node.type == :output
                    connections[(in_id, out_id)] = DummyConnection(in_id, out_id, randn(), true)
                end
            end
        end
    end

    fitness = rand()  # Random fitness for demo
    DummyGenome(id, parent_id, nodes, connections, fitness)
end

# Create dummy species genomes per generation with lineage links
num_generations = 10
species_genomes_per_gen = Vector{Vector{DummyGenome}}(undef, num_generations)

# Generation 1: no parents (parent_id = 0)
species_genomes_per_gen[1] = [create_dummy_genome(i, 0, 3, 2, 1) for i in 1:5]

# Later generations: link parent_id to genome from previous generation (same index)
for gen in 2:num_generations
    species_genomes_per_gen[gen] = [
        create_dummy_genome((gen-1)*5 + i, species_genomes_per_gen[gen-1][i].id, 3, gen % 4 + 1, 1)
        for i in 1:5
    ]
end

# Prepare fitness data for boxplot (all genomes per generation)
fitness_data = [ [g.fitness for g in gen] for gen in species_genomes_per_gen ]

# Prepare genome stats for complexity plot: average nodes & connections per generation
genome_stats = [
    [(length(g.nodes), length(g.connections)) for g in gen]
    for gen in species_genomes_per_gen
]

# --- Plot fitness boxplot and genome complexity ---
p1 = plot_fitness_boxplot(fitness_data)
p2 = plot_genome_complexity(genome_stats)

# Show side by side and save
combined_plot = plot(p1, p2, layout=(1, 2), size=(1000, 400))
display(combined_plot)
savefig(combined_plot, "fitness_and_complexity.png")
println("Saved fitness and complexity plots to fitness_and_complexity.png")

# Select best genomes per generation for animation
best_genomes = select_best_genomes(species_genomes_per_gen)

# --- Animate best genome lineage evolution ---
Visualizer.animate_species_network_evolution(best_genomes, "best_species_evolution.gif")
println("Animation saved as best_species_evolution.gif")

