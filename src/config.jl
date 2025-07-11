using TOML

"""
NeatConfig module manages NEAT algorithm parameters via an external TOML configuration file.
Provides loading of defaults, parsing, and saving of configuration settings.

Sets up AUTOMATICALLY:
creates a neat_config.toml which is editable and used for training => necessary for package use. 
Values in here are standard (dummy) values that are tested for XOR.
"""

# Default configuration for NEAT algorithm parameters
"""
DEFAULT_CONFIG :: Dict{String,Any}

A Dict specifying default settings for population, mutation, crossover, and speciation.
"""
const DEFAULT_CONFIG = Dict(
    "train_param" => Dict(
        "pop_size"            => 300,
        "n_generations"       => 200,
        "input_size"          => 2,
        "output_size"         => 1,
        "speciation_threshold" => 4.0,
        "elite_frac"          => 0.1
    ),
    "mutation" => Dict(
        "node_add_prob"         => 0.03,
        "add_connection_prob"   => 0.3,
        "sigma"                 => 0.06,
        "perturb_chance"        => 0.96,
        "max_attempts"          => 50
    ),
    "crossover" => Dict(
        "dummy"           => true
    ),
    "speciation"  => Dict(
        "c1"      => 0.5,
        "c2"      => 0.5,
        "c3"      => 3.0
    ),
    "data" => Dict(
        "training_data"         => "XOR_DATA" # or PARITY3_DATA # still dummy
    )
)

"""
_default_toml_path() -> String

Return the file path for the TOML configuration file (`neat_config.toml`) in the current working directory.
"""
function _default_toml_path()
    return joinpath(pwd(), "neat_config.toml")
end

"""
load_config() -> Dict{String,Any}

Load the configuration from `neat_config.toml`. If the file does not exist,
write the DEFAULT_CONFIG to that file first, then parse and return it.
If the file exists, log that the existing configuration is being used.
"""
function load_config()
    toml_path = _default_toml_path()
    if !isfile(toml_path)
        # Write default configuration to file
        open(toml_path, "w") do io
            TOML.print(io, DEFAULT_CONFIG)
        end
        @info "NeatConfig: Default configuration written to $(toml_path)"
    else
        #print("Setting up parameters from neat_config.toml")
    end
    return TOML.parsefile(toml_path)
end

# initially create config file
function __init__()
     load_config()
end

# get config 
function get_config()
    return load_config()
end

# Export public API
export get_config

