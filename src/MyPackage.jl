# src/mypackage.jl
module MyPackage

include("genome.jl")
include("create_genome.jl")
include("forward_pass.jl")
include("fitness.jl")

using .Types
using .CreateGenome
using .ForwardPass
using .Fitness

export Genome, Node, Connection, create_genome, forward_pass, evaluate_fitness

end # module