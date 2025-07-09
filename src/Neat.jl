# src/Neat.jl
module Neat

include("genome.jl")
include("innovation.jl")
include("create_genome.jl")
include("forward_pass.jl")
include("fitness.jl")
include("create_population.jl")
include("mutation.jl")
include("crossover.jl")
include("speciation.jl")
include("Visualizer/Visualizer.jl")

using .Types
using .CreateGenome
using .ForwardPass
using .Fitness
using .Population
using .Innovation
using .Mutation
using .Crossover
using .Speciation
using .Visualizer

export Genome,
    Node,
    Connection,
    create_genome,
    forward_pass,
    evaluate_fitness,
    initialize_population,
    get_innovation_number,
    reset_innovation_counter!,
    mutate,
    crossover,
    compatibility_distance,
    assign_species!,
    adjust_fitness!,
    compute_offspring_counts,
    select_elites,
    next_genome_id, 
    plot_genome_complexity,
    plot_fitness_boxplot,
    plot_genome_network,
    animate_species_network_evolution,
    select_best_genomes

end # module