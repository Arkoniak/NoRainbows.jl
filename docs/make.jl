using NoRainbows
using Documenter

DocMeta.setdocmeta!(NoRainbows, :DocTestSetup, :(using NoRainbows); recursive=true)

makedocs(;
    modules=[NoRainbows],
    authors="Andrey Oskin",
    repo="https://github.com/Arkoniak/NoRainbows.jl/blob/{commit}{path}#{line}",
    sitename="NoRainbows.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://Arkoniak.github.io/NoRainbows.jl",
        siteurl="https://github.com/Arkoniak/NoRainbows.jl",
    ),
    pages=[
        "Home" => "index.md",
        "Colors" => "colors.md",
        "Colorschemes" => "colorschemes.md",
        "Reverse stacktrace" => "reverse.md",
        "Frameline format" => "frameline.md",
    ],
)

deploydocs(;
    repo="github.com/Arkoniak/NoRainbows.jl",
)
