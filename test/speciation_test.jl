using Test
using Neat
using Neat: Genome, select_elites, select_parents,
             compatibility_distance, assign_species!,
             adjust_fitness!, compute_offspring_counts
using Neat.CreateGenome: create_genome

const EMPTY_WEIGHT_MAP = Dict{Tuple{Int, Int}, Float64}()

@testset "assign_species! basic structure" begin
    pop = [create_genome(i, 2, 1;
                         deterministic=true,
                         weight_map=EMPTY_WEIGHT_MAP,
                         fully_connect=true) for i in 1:4]

    for g in pop
        g.fitness = 1.0
    end

    species_list = Vector{Vector{Genome}}()
    assign_species!(pop, species_list; threshold=3.0)

    @test sum(length.(species_list)) == length(pop)
    @test all(length(s) > 0 for s in species_list)
end

# A mock struct used to test select_elites and select_parents
struct MockGenome
    adjusted_fitness::Float64
end

@testset "Speciation" begin

    @testset "compatibility_distance" begin
        g1 = create_genome(1, 2, 1;
                           deterministic=true,
                           weight_map=EMPTY_WEIGHT_MAP,
                           fully_connect=true)
        g2 = create_genome(2, 2, 1;
                           deterministic=true,
                           weight_map=EMPTY_WEIGHT_MAP,
                           fully_connect=true)

        d = compatibility_distance(g1, g2)
        @test isa(d, Float64)
        @test d ≥ 0
    end

    @testset "assign_species!" begin
        pop = [create_genome(i, 2, 1;
                             deterministic=true,
                             weight_map=EMPTY_WEIGHT_MAP,
                             fully_connect=true) for i in 1:4]

        for g in pop
            g.fitness = 1.0
        end

        species_list = Vector{Vector{Genome}}()
        assign_species!(pop, species_list; threshold=3.0)

        @test sum(length.(species_list)) == length(pop)
        @test all(length(s) > 0 for s in species_list)
    end

    @testset "adjust_fitness!" begin
        pop = [create_genome(i, 2, 1;
                             deterministic=true,
                             weight_map=EMPTY_WEIGHT_MAP,
                             fully_connect=true) for i in 1:3]

        for g in pop
            g.fitness = -1.0
        end

        species_list = [[pop[1], pop[2]], [pop[3]]]
        adjust_fitness!(species_list)

        @test pop[1].adjusted_fitness ≈ -0.5
        @test pop[2].adjusted_fitness ≈ -0.5
        @test pop[3].adjusted_fitness ≈ -1.0
    end

    @testset "compute_offspring_counts" begin
        g1 = create_genome(1, 2, 1;
                           deterministic=true,
                           weight_map=EMPTY_WEIGHT_MAP,
                           fully_connect=true)
        g2 = create_genome(2, 2, 1;
                           deterministic=true,
                           weight_map=EMPTY_WEIGHT_MAP,
                           fully_connect=true)
        g3 = create_genome(3, 2, 1;
                           deterministic=true,
                           weight_map=EMPTY_WEIGHT_MAP,
                           fully_connect=true)

        g1.fitness = 2.0
        g2.fitness = 2.0
        g3.fitness = 6.0

        species_list = [[g1, g2], [g3]]
        adjust_fitness!(species_list)

        counts = compute_offspring_counts(species_list, 10)
        @test length(counts) == 2
        @test sum(counts) == 10
        @test counts[2] > counts[1]  # more fit species gets more offspring
    end

    @testset "select_elites tests" begin
        species = [
            MockGenome(0.9),
            MockGenome(0.3),
            MockGenome(0.7),
            MockGenome(0.5),
            MockGenome(0.8)
        ]

        elite_frac = 0.4
        elites = select_elites(species, elite_frac)

        @test length(elites) == 2
        @test elites[1].adjusted_fitness ≥ elites[2].adjusted_fitness
        @test all(e.adjusted_fitness ≥ 0.7 for e in elites)

        elites_one = select_elites(species, 0.01)
        @test length(elites_one) == 1
        @test elites_one[1].adjusted_fitness == maximum(g.adjusted_fitness for g in species)
    end

    @testset "select_parents" begin
        genomes = [MockGenome(i) for i in 1:10]
        elites = select_elites(genomes, 2)
        parent_pairs = select_parents(genomes, 5; exclude=Set(elites))

        @test length(parent_pairs) == 5
        for (p1, p2) in parent_pairs
            @test !(p1 in elites)
            @test !(p2 in elites)
            @test p1 in genomes
            @test p2 in genomes
        end
    end
end
