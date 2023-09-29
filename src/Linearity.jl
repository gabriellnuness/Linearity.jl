module Linearity


export linearity


# Export struct to use in linearity functions
abstract type linMethod end
struct RMS <: linMethod end
struct Normal <: linMethod end

export linMethod, RMS, Normal



include("nonlinearity.jl")


end # module Linearity
