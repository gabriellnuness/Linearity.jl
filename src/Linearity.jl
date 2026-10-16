module Linearity


export nonlinearity
export mean_unique_vals


# Export struct to use in linearity functions
abstract type linMethod end
struct RMS <: linMethod end
struct Simple <: linMethod end
struct Sigma3 <: linMethod end

export linMethod, RMS, Simple, Sigma3


# Local dependencies
include("nonlinearity.jl")
include("auxiliary.jl")


# external dependencies
using Statistics


end # module Linearity
