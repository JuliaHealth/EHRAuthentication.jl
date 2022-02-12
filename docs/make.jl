using EHRAuthentication
using Documenter

DocMeta.setdocmeta!(EHRAuthentication, :DocTestSetup, :(using EHRAuthentication); recursive=true)

makedocs(;
    modules=[EHRAuthentication],
    authors="Dilum Aluthge, Pumas-AI Inc., and contributors",
    repo="https://github.com/JuliaHealth/EHRAuthentication.jl/blob/{commit}{path}#{line}",
    sitename="EHRAuthentication.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://JuliaHealth.github.io/EHRAuthentication.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
    strict=true,
)

deploydocs(;
    repo="github.com/JuliaHealth/EHRAuthentication.jl",
    devbranch="main",
)
