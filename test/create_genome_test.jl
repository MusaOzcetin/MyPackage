using Test
using Neat

@testset "create_genome" begin
    # Example: 2 inputs, 1 output
    genome = Neat.CreateGenome.create_genome(1, 2, 1)


    # --- Check Genome Type and Fields ---
    @test isa(genome, Genome)
    @test genome.id == 1
    @test genome.fitness == 0.0
    @test genome.adjusted_fitness == 0.0


    # --- Check node count ---
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

end
