using MyPackage
using Test

@testset "MyPackage.jl" begin
        include("forward_pass_test.jl")
        include("evaluate_fitness_test.jl")
        include("create_genome_test.jl")
        include("types_test.jl")
end

