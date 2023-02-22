println("--- :julia: Instantiating project")
using Pkg
Pkg.activate("..")
Pkg.instantiate()
Pkg.activate(".")
Pkg.instantiate()
push!(LOAD_PATH, joinpath(@__DIR__, ".."))
deleteat!(LOAD_PATH, 2)
println("+++ :julia: Building documentation")
include("make.jl")
