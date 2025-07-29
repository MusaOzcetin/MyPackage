module Visualize

using Plots
using ..Types: Genome
using Plots

export plot_fitness_history

"""
    plot_fitness_history(best_fitness_history; filename="fitness_history.png")

Create and save a line plot of the best fitness values over generations.

# Arguments
- `best_fitness_history::Vector{Float64}`: History of best fitness per generation.
- `filename::String`: Output file path (defaults to "fitness_history.png").
"""
function plot_fitness_history(best_fitness_history::Vector{Float64}; filename::String="fitness_history.png")
    p = plot(
        best_fitness_history,
        xlabel = "Generation",
        ylabel = "Best Fitness",
        title = "Evolution of Best Genome Fitness",
        legend = false,
        seriestype = :line,
    )
    savefig(p, filename)
    return p

end # module Visualize
