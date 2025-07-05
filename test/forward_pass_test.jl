using Test
using Neat
<<<<<<< HEAD
<<<<<<< HEAD

@testset "forward_pass" begin
    # --- Create dummy nodes ---
    nodes = Dict(
        1 => Neat.Types.Node(1, :input),
        2 => Neat.Types.Node(2, :input),
        3 => Neat.Types.Node(3, :output)
=======
using Neat.CreateGenome
using Neat.ForwardPass

@testset "forward_pass" begin
=======
using Neat.CreateGenome
using Neat.ForwardPass

@testset "forward_pass" begin
>>>>>>> 7e7303f5732b09d3f06ee3cfd775bc44561e1693
    # Create a minimal genome with 2 inputs, 1 bias, and 1 output (node 4)
    nodes = Dict(
        1 => Node(1, :input),
        2 => Node(2, :input),
        3 => Node(3, :bias),
        4 => Node(4, :output)
    )

    connections = Dict(
        (1, 4) => Connection(1, 4, 0.5, true, 1),
        (2, 4) => Connection(2, 4, -1.0, true, 2),
        (3, 4) => Connection(3, 4, 1.0, true, 3)  # bias → output
<<<<<<< HEAD
>>>>>>> f610ce6 (Added bias and modified tests accordingly)
    )

<<<<<<< HEAD
    # --- Create dummy connections ---
    connections = Dict(
        (1, 3) => Neat.Types.Connection(1, 3, 0.5, true, 1),
        (2, 3) => Neat.Types.Connection(2, 3, -1.0, true, 2)
    )



    # --- Create genome ---
    genome = Neat.Types.Genome(1, nodes, connections, 0.0, 0.0)

    # --- Input vector ---
=======
    genome = Genome(1, nodes, connections, 0.0, 0.0)
<<<<<<< HEAD
>>>>>>> 09dfa74 (updated speciation.jl with adjusted fitness)
    input = [1.0, 2.0]

    # --- Run forward_pass ---
    activations = Neat.ForwardPass.forward_pass(genome, input)

    # --- Compute expected output ---
    expected_sum = 1.0 * 0.5 + 2.0 * -1.0  # = -1.5
    expected_output = 1.0 / (1.0 + exp(-expected_sum))  # sigmoid(-1.5)

    # --- Extract actual output node activation ---
    output_nodes = [n.id for n in values(nodes) if n.nodetype == :output]
    @test length(output_nodes) == 1  # ensure only one output
    output_value = activations[output_nodes[1]]

    @test isapprox(output_value, expected_output; atol=1e-6)
=======
    input = [2.0, 1.0]  # input[1] to node 1, input[2] to node 2

    # Expected sum: 2*0.5 + 1*-1.0 + 1*1.0 = 1.0 → sigmoid(1.0)
    expected_sum = 2.0 * 0.5 + 1.0 * -1.0 + 1.0 * 1.0
    expected_output = 1.0 / (1.0 + exp(-expected_sum))

=======
    )

    genome = Genome(1, nodes, connections, 0.0, 0.0)
    input = [2.0, 1.0]  # input[1] to node 1, input[2] to node 2

    # Expected sum: 2*0.5 + 1*-1.0 + 1*1.0 = 1.0 → sigmoid(1.0)
    expected_sum = 2.0 * 0.5 + 1.0 * -1.0 + 1.0 * 1.0
    expected_output = 1.0 / (1.0 + exp(-expected_sum))

>>>>>>> 7e7303f5732b09d3f06ee3cfd775bc44561e1693
    output = forward_pass(genome, input)
    @test isapprox(output, expected_output; atol=1e-6)
>>>>>>> f610ce6 (Added bias and modified tests accordingly)
end

@testset "Forward Pass Includes Bias Contribution" begin
    num_inputs = 2
    num_outputs = 1
    input = [2.0, 1.0]  # consistent with above: node 1 → 2.0, node 2 → 1.0

    # Define deterministic weights for connections
    weight_map = Dict(
        (1, 4) => 0.5,   # input 1 to output
        (2, 4) => -1.0,  # input 2 to output
        (3, 4) => 1.0    # bias to output
    )

    genome = CreateGenome.create_genome(1, num_inputs, num_outputs;
                                        deterministic=true,
                                        weight_map=weight_map)

    # Compute expected output: 2*0.5 + 1*-1.0 + 1*1.0 = 1.0 → sigmoid(1.0)
    input_sum = 2.0 * 0.5 + 1.0 * -1.0
    bias_sum = 1.0 * 1.0
    total = input_sum + bias_sum
    expected = 1.0 / (1.0 + exp(-total))

    result = forward_pass(genome, input)

    @test isapprox(result, expected; atol=1e-6)
end

