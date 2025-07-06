using Test
using Neat

@testset "create_genome" begin
     # Reset the innovation counter so tests are deterministic
    Neat.Innovation.reset_innovation_counter!()
    # Example: 2 inputs, 1 output
    genome = Neat.CreateGenome.create_genome(2, 1)


    # --- Check Genome Type and Fields ---
    @test isa(genome, Genome)
    @test genome.id == 1
    @test genome.fitness == 0.0
    @test genome.adjusted_fitness == 0.0

    @test length(genome.nodes) == 3  # 2 inputs + 1 output

    # --- Check connection count (should be inputs * outputs) ---
    @test length(genome.connections) == 2  # 2 * 1 = 2

    # --- Check Node Creation ---
    @test length(genome.nodes) == 3  # 2 inputs + 1 output
    @test genome.nodes[1].nodetype == :input
    @test genome.nodes[2].nodetype == :input
    @test genome.nodes[3].nodetype == :output


    # --- Check that each input connects to each output ---
    for input_id in 1:2
        output_id = 3  # only one output node
        @test haskey(genome.connections, (input_id, output_id))
        conn = genome.connections[(input_id, output_id)]
        @test conn.enabled == true
        @test conn.in_node == input_id
        @test conn.out_node == output_id
    end

    # --- Check innovation numbers are unique and sequential starting at 3---
    innov_numbers = [conn.innovation_number for conn in values(genome.connections)]
    expected_innov = collect(3:3+length(innov_numbers)-1)
    @test innov_numbers == expected_innov

end

