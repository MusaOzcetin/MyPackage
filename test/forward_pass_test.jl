using Test
using Neat

@testset "forward_pass" begin
    # --- Create dummy nodes ---
    nodes = Dict(
        1 => Neat.Types.Node(1, :input),
        2 => Neat.Types.Node(2, :input),
        3 => Neat.Types.Node(3, :output)
    )

    # --- Create dummy connections ---
    connections = Dict(
        (1, 3) => Neat.Types.Connection(1, 3, 0.5, true, 1),
        (2, 3) => Neat.Types.Connection(2, 3, -1.0, true, 2)
    )

    # --- Create genome ---
    genome = Neat.Types.Genome(1, nodes, connections, 0.0)

    # --- Input vector ---
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
end
