module Champion

using ..Types

export preserve_champion

"""
    preserve_champion!(population::Vector{Genome}, champion::Genome)

Inserts the champion into the population by overwriting the worst-performing genome,
ensuring the champion remains unchanged (deep-copied).
"""

function preserve_champion(population::Vector{Genome}, champion::Genome)
    
    champ = deepcopy(champion)
    fitnesses = [g.fitness for g in population]
    worst_idx = argmin(fitnesses)
    population[worst_idx] = champ

    return population
end

end # module