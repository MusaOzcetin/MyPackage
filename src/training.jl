module NeatTrain

using Random
using Plots
using ..NeatConfig: get_config
using ..Types
using ..CreateGenome
using ..ForwardPass: forward_pass
using ..Fitness: evaluate_fitness
using ..Population
using ..Speciation
using ..Mutation: mutate
using ..Crossover: crossover
using ..Visualize: plot_fitness_history

export train

"""
    train(; pop_size::Int = get_config()["train_param"]["pop_size"],
            n_generations::Int = get_config()["train_param"]["n_generations"],
            input_size::Int = get_config()["train_param"]["input_size"],
            output_size::Int = get_config()["train_param"]["output_size"],
            speciation_threshold::Float64 = get_config()["train_param"]["speciation_threshold"],
            elite_frac::Float64 = get_config()["train_param"]["elite_frac"],
            perturb_chance::Float64 = get_config()["mutation"]["perturb_chance"],
            sigma::Float64 = get_config()["mutation"]["sigma"],
            add_connection_prob::Float64 = get_config()["mutation"]["add_connection_prob"],
            node_add_prob::Float64 = get_config()["mutation"]["node_add_prob"],
            max_attempts::Int = get_config()["mutation"]["max_attempts"],
            c1::Float64 = get_config()["speciation"]["c1"],
            c2::Float64 = get_config()["speciation"]["c2"],
            c3::Float64 = get_config()["speciation"]["c3"],
            ds_name::String = get_config()["data"]["training_data"]) -> (Vector{Genome}, Vector{Float64})

Runs the full NEAT evolutionary training loop, returning the final evolved population
and the history of the best fitness values per generation.

All keyword arguments are initialized using the values from the configuration file unless explicitly provided.

# Keyword Arguments
- `pop_size`              : Total number of genomes in each generation.
- `n_generations`         : Number of generations to evolve.
- `input_size`            : Number of input neurons in each genome.
- `output_size`           : Number of output neurons.
- `speciation_threshold`  : Compatibility distance threshold for species assignment.
- `elite_frac`            : Fraction of top genomes preserved as elites within each species.
- `perturb_chance`        : Probability of applying small mutations to connection weights.
- `sigma`                 : Standard deviation used for small weight perturbations.
- `add_connection_prob`   : Probability of attempting to add a new connection.
- `node_add_prob`         : Probability of attempting to add a new node.
- `max_attempts`          : Maximum number of attempts when trying to add a connection.
- `c1`, `c2`, `c3`        : Coefficients for excess, disjoint, and weight-difference terms in compatibility distance calculations.
- `ds_name`               : Name of the training dataset (e.g., `"XOR_DATA"` or `"PARITY3_DATA"`).

# Behavior

1. Initializes a population with `pop_size` genomes, each fully connected from input to output nodes.
2. For each generation:
   - Evaluates raw fitness using `evaluate_fitness`.
   - Records the highest fitness in `best_fitness_history`.
   - Groups genomes into species based on compatibility distances.
   - Applies fitness sharing and selects elites for each species.
   - Allocates offspring based on adjusted fitness.
   - Generates offspring through crossover and mutation.
3. Re-evaluates the final population's fitness after evolution.
4. Plots and saves the trajectory of best fitness per generation to `"fitness.png"`.

# Returns
- `population`           : Vector of `Genome` objects representing the final generation.
- `best_fitness_history` : Vector containing the highest fitness value from each generation.
"""

function train(
    ;
    pop_size::Int                  = get_config()["train_param"]["pop_size"],
    n_generations::Int             = get_config()["train_param"]["n_generations"],
    input_size::Int                = get_config()["train_param"]["input_size"],
    output_size::Int               = get_config()["train_param"]["output_size"],
    speciation_threshold::Float64  = get_config()["train_param"]["speciation_threshold"],
    elite_frac::Float64            = get_config()["train_param"]["elite_frac"],
    perturb_chance::Float64        = get_config()["mutation"]["perturb_chance"],
    sigma::Float64                 = get_config()["mutation"]["sigma"],
    add_connection_prob::Float64   = get_config()["mutation"]["add_connection_prob"],
    node_add_prob::Float64         = get_config()["mutation"]["node_add_prob"],
    max_attempts::Int              = get_config()["mutation"]["max_attempts"],
    c1::Float64                     = get_config()["speciation"]["c1"],
    c2::Float64                     = get_config()["speciation"]["c2"],
    c3::Float64                     = get_config()["speciation"]["c3"],
    ds_name::String                = get_config()["data"]["training_data"],
)
    # Initialize the population
    population = initialize_population(pop_size, input_size, output_size)
    best_fitness_history = Float64[]

    for generation in 1:n_generations
        # Evaluate fitness for each genome
        for genome in population
            genome.fitness = evaluate_fitness(genome, ds_name = ds_name)
        end
        # Record the best fitness of this generation


        best_fitness = maximum(g -> g.fitness, population)
        println("Generation $generation: Best fitness = $(best_fitness)")

        push!(best_fitness_history, best_fitness)

        species_list = Vector{Vector{Genome}}()
        assign_species!(population, species_list;
                        speciation_threshold=speciation_threshold,
                        c1=c1, c2=c2, c3=c3)
        adjust_fitness!(species_list)

        # Determine offspring counts for each species
        offspring_counts = compute_offspring_counts(species_list, pop_size)

        # Create new population via crossover and mutation
        new_population = Genome[]
        for (species, count) in zip(species_list, offspring_counts)
            isempty(species) && continue
            # Select elites; if fewer than 2 elites, use entire species
            elites = select_elites(species, elite_frac)
            mating_pool = length(elites) >= 2 ? elites : species

            for _ in 1:count
                parent1, parent2 = rand(mating_pool, 2)
                child = crossover(parent1, parent2)
                mutate(child;
                       perturb_chance=perturb_chance,
                       sigma=sigma,
                       add_connection_prob=add_connection_prob,
                       node_add_prob=node_add_prob,
                       max_attempts=max_attempts)
                push!(new_population, child)
            end
        end
        population = new_population
    end

    # Final fitness evaluation for the evolved population
    for genome in population
        genome.fitness = evaluate_fitness(genome, ds_name = ds_name)
    end

    plot_fitness_history(best_fitness_history; filename="fitness_history.png")

    best_genome = argmax(g -> g.fitness, population)
  
    visualize_genome(best_genome)

    return population, best_fitness_history


end  # module NeatTrain
