using Test
using Neat
using Neat.CreateGenome: create_genome
using Neat.Mutation: mutate, mutate_weights!, add_connection!, add_node!
using Neat.Types: Genome

@testset "Mutation Operators" begin
    @testset "mutate_weights!" begin
        genome = create_genome(1, 2, 1)
        old_weights = [c.weight for c in values(genome.connections)]
        mutate_weights!(genome; perturb_chance=1.0, sigma=0.1)
        new_weights = [c.weight for c in values(genome.connections)]
        @test any(abs.(old_weights .- new_weights) .> 0)
    end

    @testset "add_connection! with hidden node" begin
        genome = create_genome(1, 2, 1)
        add_node!(genome)
        num_connections_before = length(genome.connections)
        add_connection!(genome)
        num_connections_after = length(genome.connections)
        @test num_connections_after >= num_connections_before
    end

    @testset "add_node!" begin
        genome = create_genome(1, 2, 1)
        num_nodes_before = length(genome.nodes)
        num_connections_before = length(genome.connections)
        add_node!(genome)
        num_nodes_after = length(genome.nodes)
        num_connections_after = length(genome.connections)
        @test num_nodes_after == num_nodes_before + 1
        @test num_connections_after == num_connections_before + 2

        num_disabled = count(!c.enabled for c in values(genome.connections))
        @test num_disabled == 1
    end

    @testset "mutate (full pipeline)" begin
        genome = create_genome(1, 2, 1)
        mutate(genome)
        @test length(genome.nodes) >= 3
        @test all(
            conn.in_node in keys(genome.nodes) && conn.out_node in keys(genome.nodes)
            for conn in values(genome.connections)
        )
    end
end

@testset "add_connection! cycle prevention" begin
    genome = create_genome(1, 2, 1;
                           deterministic=true,
                           weight_map=Dict{Tuple{Int, Float64}}(),
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
    genome = create_genome(2, num_inputs, num_outputs;
                           deterministic=true,
                           weight_map=Dict{Tuple{Int, Int}, Float64}(),
                           fully_connect=false)

    original_connection_count = length(genome.connections)
    found_bias_connection = false
    added = false

    for i in 1:200
        add_connection!(genome)
        new_count = length(genome.connections)

        if new_count > original_connection_count
            added = true
            original_connection_count = new_count
        end

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

    @test added
    @test found_bias_connection ||
        @warn "Bias node was not used in mutation after 200 attempts. Check bias eligibility in add_connection!"
    @test found_bias_connection
end
