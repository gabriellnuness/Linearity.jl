module Linearity


export nonlinearity
export mean_unique_vals


# Export struct to use in linearity functions
abstract type linMethod end
struct RMS <: linMethod end
struct Simple <: linMethod end

export linMethod, RMS, Simple



include("nonlinearity.jl")

using Statistics


end # module Linearity
