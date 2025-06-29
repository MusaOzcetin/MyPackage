using Test
using Neat

@testset "create_genome" begin
    # Example: 2 inputs, 1 output
    genome = Neat.CreateGenome.create_genome(1, 2, 1)

<<<<<<< HEAD

=======
>>>>>>> 09dfa74 (updated speciation.jl with adjusted fitness)
    # --- Check Genome Type and Fields ---
    @test isa(genome, Genome)
    @test genome.id == 1
    @test genome.fitness == 0.0
    @test genome.adjusted_fitness == 0.0

<<<<<<< HEAD
    @test length(genome.nodes) == 3  # 2 inputs + 1 output

    # --- Check connection count (should be inputs * outputs) ---
    @test length(genome.connections) == 2  # 2 * 1 = 2

=======
>>>>>>> 09dfa74 (updated speciation.jl with adjusted fitness)
    # --- Check Node Creation ---
    @test length(genome.nodes) == 3  # 2 inputs + 1 output
    @test genome.nodes[1].nodetype == :input
    @test genome.nodes[2].nodetype == :input
    @test genome.nodes[3].nodetype == :output

<<<<<<< HEAD

    # --- Check that each input connects to each output ---
    for input_id in 1:2
        for output_id in 3:3  # output IDs start at num_inputs + 1
            @test haskey(genome.connections, (input_id, output_id))
            conn = genome.connections[(input_id, output_id)]
            @test conn.enabled == true
            @test conn.in_node == input_id
            @test conn.out_node == output_id
        end
    end

    # --- Check innovation numbers are unique and sequential ---
    innov_numbers = [conn.innovation_number for conn in values(genome.connections)]
    @test innov_numbers == collect(1:length(innov_numbers))

=======
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
>>>>>>> 09dfa74 (updated speciation.jl with adjusted fitness)
end

