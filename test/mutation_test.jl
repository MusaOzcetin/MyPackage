using Test
using Neat
using Neat.Mutation: causes_cycle, add_connection!

@testset "add_connection! cycle prevention" begin
    genome = create_genome(1, 2, 1)

    # Apply many connection mutations
    for _ in 1:50
        add_connection!(genome)
    end

    # Function to check the entire graph for any cycles
    function has_cycle(genome::Genome)::Bool
        visited = Set{Int}()
        stack = Set{Int}()

        function visit(node_id::Int)
            if node_id in stack
                return true  # Found a cycle
            end
            if node_id in visited
                return false
            end
            push!(visited, node_id)
            push!(stack, node_id)

            for conn in values(genome.connections)
                if conn.enabled && conn.in_node == node_id
                    if visit(conn.out_node)
                        return true
                    end
                end
            end

            delete!(stack, node_id)
            return false
        end

        for node_id in keys(genome.nodes)
            if visit(node_id)
                return true
            end
        end
        return false
    end

    # TODO: delete this part before making it final
    println("Nodes in genome:")
        for (id, node) in genome.nodes
    println(" - ID $id : ", node.nodetype)
        end
       println("Connections in genome:")
        for ((src, dst), conn) in genome.connections
    println(" - $src → $dst (enabled=$(conn.enabled), weight=$(conn.weight))")
        end
 

    # Assert that no cycle exists after all mutations
    @test !has_cycle(genome)
end
