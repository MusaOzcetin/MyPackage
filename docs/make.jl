using Neat
using Documenter

DocMeta.setdocmeta!(Neat, :DocTestSetup, :(using Neat); recursive=true)

makedocs(;
    modules=[Neat],
    authors="Musa Ozcetin <musa.oezcetin@campus.tu-berlin.de>",
    sitename="Neat.jl",
    format=Documenter.HTML(;
        canonical="https://MusaOzcetin.github.io/Neat.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Getting Started" => "getting_started.md",
        "Overview" => "overview.md",
    ],
)

deploydocs(;
    repo="github.com/MusaOzcetin/Neat.jl",
    devbranch="main",
)
