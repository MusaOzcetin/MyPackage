using Test
using Neat

@testset "create_genome" begin
<<<<<<< HEAD
    # Example: 2 inputs, 1 output
    genome = Neat.CreateGenome.create_genome(1, 2, 1)
=======
    genome = create_genome(1, 2, 1; deterministic=true, weight_map=Dict{Tuple{Int, Int}, Float64}())
>>>>>>> f610ce6 (Added bias and modified tests accordingly)

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
    # 2 inputs + 1 bias + 1 output = 4 total nodes
    @test length(genome.nodes) == 4

    @test genome.nodes[1].nodetype == :input
    @test genome.nodes[2].nodetype == :input
    @test genome.nodes[3].nodetype == :bias
    @test genome.nodes[4].nodetype == :output

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
    # Now 3 connections: input1 → output, input2 → output, bias → output
    @test length(genome.connections) == 3
    @test haskey(genome.connections, (1, 4))
    @test haskey(genome.connections, (2, 4))
    @test haskey(genome.connections, (3, 4))  # bias → output

    c1 = genome.connections[(1, 4)]
    c2 = genome.connections[(2, 4)]
    c3 = genome.connections[(3, 4)]  # bias connection

    @test isa(c1, Connection)
    @test isa(c2, Connection)
    @test isa(c3, Connection)

    @test c1.in_node == 1 && c1.out_node == 4
    @test c2.in_node == 2 && c2.out_node == 4
    @test c3.in_node == 3 && c3.out_node == 4

    @test c1.enabled
    @test c2.enabled
    @test c3.enabled

    @test c1.innovation_number == 1
    @test c2.innovation_number == 2
    @test c3.innovation_number == 3

    @test isfinite(c1.weight)
    @test isfinite(c2.weight)
<<<<<<< HEAD
<<<<<<< HEAD
>>>>>>> 09dfa74 (updated speciation.jl with adjusted fitness)
end

=======
end
>>>>>>> ac9760e (fixed cycle logic and added mutation_test.jl)
=======
    @test isfinite(c3.weight)
    # --- Check Bias to Output Connection Exists ---
    @testset "Bias to Output Connection Exists" begin
        num_inputs = 2
        num_outputs = 1
        bias_id = num_inputs + 1
        output_id = bias_id + 1
        @test haskey(genome.connections, (bias_id, output_id))
    end
end
>>>>>>> f610ce6 (Added bias and modified tests accordingly)
