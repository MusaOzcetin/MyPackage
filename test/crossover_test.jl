using Test
using Neat

@testset "crossover" begin
    # Create nodes
    nodes = Dict(
        1 => Node(1, :input),
        2 => Node(2, :input),
        3 => Node(3, :output),
        4 => Node(4, :hidden),
    )

    # Parent 1: has 2 connections
    conn1 = Connection(1, 3, 1.0, true, 1)
    conn2 = Connection(2, 3, 1.0, true, 2)
    p1 = Genome(1, copy(nodes), Dict((1, 3)=>conn1, (2, 3)=>conn2), -0.5, 0.0)

    # Parent 2: one matching, one disjoint gene
    conn2p2 = Connection(2, 3, 2.0, false, 2)  # matching but disabled
    conn3p2 = Connection(1, 4, 0.5, true, 3)   # disjoint/excess
    p2 = Genome(2, copy(nodes), Dict((2, 3)=>conn2p2, (1, 4)=>conn3p2), -1.0, 0.0)

    child = crossover(p1, p2)

    @test isa(child, Genome)
    @test length(child.nodes) ≥ 3
    @test all(conn isa Connection for conn in values(child.connections))

    # Ensure child only has genes from parent1 or matching genes
    valid_innovs = Set([1, 2])  # parent1 is fitter
    @test all(conn.innovation_number in valid_innovs for conn in values(child.connections))

    # Optional: test disabled gene rule
    conn = get(child.connections, (2, 3), nothing)
    if conn !== nothing
        @test conn.weight == 1.0 || conn.weight == 2.0
    end
end
