using Test
using Neat

@testset "create_genome" begin
    genome = create_genome(1, 2, 1)

    # --- Check Genome Type and Fields ---
    @test isa(genome, Genome)
    @test genome.id == 1
    @test genome.fitness == 0.0
    @test genome.adjusted_fitness == 0.0

    # --- Check Node Creation ---
    @test length(genome.nodes) == 3  # 2 inputs + 1 output
    @test genome.nodes[1].nodetype == :input
    @test genome.nodes[2].nodetype == :input
    @test genome.nodes[3].nodetype == :output

    # --- Check Connection Structure ---
    @test length(genome.connections) == 2
    @test haskey(genome.connections, (1, 3))
    @test haskey(genome.connections, (2, 3))

    c1 = genome.connections[(1, 3)]
    c2 = genome.connections[(2, 3)]

    @test isa(c1, Connection)
    @test isa(c2, Connection)

    @test c1.in_node == 1 && c1.out_node == 3
    @test c2.in_node == 2 && c2.out_node == 3

    @test c1.enabled
    @test c2.enabled

    @test c1.innovation_number == 1
    @test c2.innovation_number == 2

    @test isfinite(c1.weight)
    @test isfinite(c2.weight)
end