
module Visualization

using Plots

export plot_fitness, plot_genome_evolution, plot_species_evolution




"Plot fitness over generations."
function plot_fitness(fitness_history::AbstractVector{<:Real})
    plot(fitness_history, xlabel="Generation", ylabel="Fitness", title="Fitness Over Time", label="Fitness", lw=2)
end

"Plot genome count (or another property) over generations."
function plot_genome_evolution(genome_counts::AbstractVector{<:Real})
    plot(genome_counts, xlabel="Generation", ylabel="Genome Metric", title="Genome Evolution", label="Genomes", lw=2)
end

"Plot number of species over generations."
function plot_species_evolution(species_counts::AbstractVector{<:Real})
    plot(species_counts, xlabel="Generation", ylabel="Species Count", title="Species Evolution", label="Species", lw=2)
end

end # module

