using Test
using Neat
using Neat.CreateGenome: create_genome
using Neat.Mutation: add_connection!
using Neat.Types: Genome

@testset "add_connection! cycle prevention" begin
    genome = create_genome(1, 2, 1;
                           deterministic=true,
                           weight_map=Dict{Tuple{Int, Int}, Float64}(),
                           fully_connect=false)

    success = true
    try
        for _ in 1:50
            add_connection!(genome)
        end
    catch e
        @warn "add_connection! threw an error" exception = e
        success = false
    end
    @test success

    # Check for cycle presence
    function has_cycle(genome::Genome)::Bool
        visited = Set{Int}()
        function dfs(node::Int, stack::Set{Int})
            if node in stack
                return true
            end
            if node in visited
                return false
            end
            push!(visited, node)
            push!(stack, node)
            for conn in values(genome.connections)
                if conn.enabled && conn.in_node == node
                    if dfs(conn.out_node, stack)
                        return true
                    end
                end
            end
            delete!(stack, node)
            return false
        end
        for node_id in keys(genome.nodes)
            if dfs(node_id, Set{Int}())
                return true
            end
        end
        return false
    end

    @test !has_cycle(genome)
end

@testset "Bias Node Used in Mutation" begin
    num_inputs = 3
    num_outputs = 2
    bias_id = num_inputs + 1
    weight_map = Dict{Tuple{Int, Int}, Float64}()

    genome = create_genome(2, num_inputs, num_outputs;
                           deterministic=true,
                           weight_map=weight_map,
                           fully_connect=false)

    original_connection_count = length(genome.connections)
    found_bias_connection = false
    added = false

    for i in 1:200  # Try more times to increase odds
        add_connection!(genome)
        new_count = length(genome.connections)

        if new_count > original_connection_count
            added = true
            original_connection_count = new_count
        end

        # Check new connections for bias usage
        for (src, dst) in keys(genome.connections)
            if src == bias_id && genome.nodes[dst].nodetype in (:hidden, :output)
                found_bias_connection = true
                break
            end
        end

        if found_bias_connection
            break
        end
    end

    @test added  # Ensure at least one connection was added

    @test found_bias_connection ||
        @warn "Bias node was not used in mutation after 200 attempts. Check bias eligibility in add_connection!"

    @test found_bias_connection
end
