using Pkg
Pkg.activate(joinpath(@__DIR__, ".."))
using Neat
using Neat.Visualizer
using Plots

"""
Run a NEAT evolutionary algorithm training loop, record statistics, and generate visualizations.

# Keyword Arguments
- `pop_size::Int`: Number of genomes in the population (default: 150).
- `n_generations::Int`: Number of generations to evolve (default: 100).
- `input_size::Int`: Number of input nodes in each genome (default: 2).
- `output_size::Int`: Number of output nodes in each genome (default: 1).
- `speciation_threshold::Float64`: Compatibility threshold for species assignment (default: 0.3).
- `elite_frac::Float64`: Fraction of each species preserved as elites for reproduction (default: 0.3).

# Returns
- `final_population::Vector{Genome}`: The population of genomes after the final generation.
"""

function train(;
    pop_size=150,
    n_generations=100,
    input_size=2,
    output_size=1,
    speciation_threshold=0.3,
    elite_frac=0.3
)
    population = initialize_population(pop_size, input_size, output_size)

    best_fitness_history = Float64[]
    genome_stats            = Vector{Vector{Tuple{Int, Int}}}(undef, n_generations)
    species_genomes_per_gen = Vector{Vector{Genome}}(undef, n_generations)

    for gen in 1:n_generations
        # evaluate
        for g in population
            g.fitness = evaluate_fitness(g)
        end

        # record best fitness and stats
        push!(best_fitness_history, maximum(g -> g.fitness, population))
        genome_stats[gen]     = [(length(g.nodes), length(g.connections)) for g in population]
        species_genomes_per_gen[gen] = deepcopy(population)

        # speciate & reproduce
        species_list = Vector{Vector{Genome}}()
        assign_species!(population, species_list; threshold=speciation_threshold)
        adjust_fitness!(species_list)
        offspring_counts = compute_offspring_counts(species_list, pop_size)

        newpop = Genome[]
        for (sp, cnt) in zip(species_list, offspring_counts)
            if isempty(sp); continue; end
            elites = select_elites(sp, elite_frac)
            pool   = length(elites) ≥ 2 ? elites : sp
            for _ in 1:cnt
                p1, p2 = rand(pool, 2)
                child  = crossover(p1, p2)
                mutate(child)
                push!(newpop, child)
            end
        end
        population = newpop
    end

    # final evaluation
    for g in population
        g.fitness = evaluate_fitness(g)
    end

    ########## Visualizations ##########
    mkpath("plots")

    # 1) Best fitness over time
    p1 = plot(best_fitness_history;
        xlabel="Generation",
        ylabel="Best Fitness",
        title="Evolution of Best Genome Fitness",
        legend=false)
    savefig(p1, "plots/fitness.png")

    # 2) Genome complexity over time
    p3 = Neat.Visualizer.plot_genome_complexity(genome_stats)
    savefig(p3, "plots/genome_complexity.png")

    # 3) Animated network evolution
    best_genomes = Neat.Visualizer.select_best_genomes(species_genomes_per_gen)
    Neat.Visualizer.animate_species_network_evolution(
        best_genomes,
        "plots/best_species_evolution.gif"
    )

    println("All visuals saved into plots/:")
    println("   • plots/fitness.png")
    println("   • plots/genome_complexity.png")
    println("   • plots/best_species_evolution.gif")

    return population
end

# kick it off
train(; pop_size=200, n_generations=100, speciation_threshold=4.0, elite_frac=0.1)
