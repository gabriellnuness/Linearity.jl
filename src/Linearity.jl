module Linearity


export nonlinearity


# Export struct to use in linearity functions
abstract type linMethod end
struct RMS <: linMethod end
struct Simple <: linMethod end

export linMethod, RMS, Simple



include("nonlinearity.jl")


end # module Linearity
