using MyPackage
using Documenter

DocMeta.setdocmeta!(MyPackage, :DocTestSetup, :(using MyPackage); recursive=true)

makedocs(;
    modules=[MyPackage],
    authors="Musa Ozcetin <musa.oezcetin@campus.tu-berlin.de>",
    sitename="MyPackage.jl",
    format=Documenter.HTML(;
        canonical="https://MusaOzcetin.github.io/MyPackage.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/MusaOzcetin/MyPackage",
    devbranch="main",
)
