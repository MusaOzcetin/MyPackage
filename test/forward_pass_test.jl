using Test
using Neat
using Neat.CreateGenome
using Neat.ForwardPass

@testset "forward_pass with hardcoded nodes" begin
    # Manually define nodes
    nodes = Dict(
        1 => Node(1, :input),
        2 => Node(2, :input),
        3 => Node(3, :bias),
        4 => Node(4, :output)
    )

    # Manually define connections: 1→4 (0.5), 2→4 (-1.0), 3→4 (1.0)
    connections = Dict(
        (1, 4) => Connection(1, 4, 0.5, true, 1),
        (2, 4) => Connection(2, 4, -1.0, true, 2),
        (3, 4) => Connection(3, 4, 1.0, true, 3)
    )

    genome = Genome(1, nodes, connections, 0.0, 0.0)
    input = [2.0, 1.0]  # node 1: 2.0, node 2: 1.0

    # Expected activation: sigmoid(2*0.5 + 1*-1.0 + 1*1.0) = sigmoid(1.0)
    expected_sum = 2.0 * 0.5 + 1.0 * -1.0 + 1.0 * 1.0
    expected_output = 1.0 / (1.0 + exp(-expected_sum))

    result = forward_pass(genome, input)
    @test isapprox(result, expected_output; atol=1e-6)
end

@testset "forward_pass using create_genome with weight_map" begin
    num_inputs = 2
    num_outputs = 1
    input = [2.0, 1.0]

    weight_map = Dict(
        (1, 4) => 0.5,
        (2, 4) => -1.0,
        (3, 4) => 1.0
    )

    genome = create_genome(1, num_inputs, num_outputs;
                           deterministic=true,
                           weight_map=weight_map)

    expected_sum = 2.0 * 0.5 + 1.0 * -1.0 + 1.0 * 1.0
    expected_output = 1.0 / (1.0 + exp(-expected_sum))

    result = forward_pass(genome, input)
    @test isapprox(result, expected_output; atol=1e-6)
end