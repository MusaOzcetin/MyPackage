using Test
using Neat 

@testset "forward_pass" begin
    # Define dummy nodes and connections
    nodes = Dict(1 => Node(1, :input), 2 => Node(2, :input), 3 => Node(3, :output))

    connections = Dict(
        (1, 3) => Connection(1, 3, 0.5, true, 1), (2, 3) => Connection(2, 3, -1.0, true, 2)
    )

    genome = Genome(1, nodes, connections, 0.0, 0.0)
    input = [1.0, 2.0]

    output = forward_pass(genome, input)

    expected_sum = 1.0 * 0.5 + 2.0 * -1.0  # = -1.5
    expected_output = 1.0 / (1.0 + exp(-expected_sum))  # sigmoid(-1.5)

    @test isapprox(output, expected_output; atol=1e-6)
end
