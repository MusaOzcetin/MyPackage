using Test
using Neat

@testset "Types - Node, Connection, Genome" begin
    # Test Node
    node = Node(1, :input)
    @test isa(node, Node)
    @test node.id == 1
    @test node.nodetype == :input

    # Test Connection
    conn = Connection(1, 2, 0.5, true, 42)
    @test isa(conn, Connection)
    @test conn.in_node == 1
    @test conn.out_node == 2
    @test conn.weight ≈ 0.5
    @test conn.enabled == true
    @test conn.innovation_number == 42

    # Test Genome
    nodes = Dict(1 => Node(1, :input), 2 => Node(2, :output))
    connections = Dict((1, 2) => conn)
    genome = Genome(99, nodes, connections, 0.0, 0.0)

    @test isa(genome, Genome)
    @test genome.id == 99
    @test genome.nodes[1].nodetype == :input
    @test genome.connections[(1, 2)].weight ≈ 0.5
end
