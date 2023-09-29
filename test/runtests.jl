using Test
using Linearity
using PyPlot


@testset "Nonlienarity test" begin

x = [0,1,2,3,4,5,6]
y = x #[1.2, 1.9, 3.1, 4.1, 4.9, 6]


# default test
lin = linearity(x,y)

figure()
plot(x, y,".")
plot(x, lin.y_fit)
ax = twinx()
ax.plot(x,lin.nonlinearity)


# rms test
lin = linearity(x, y, RMS)
@test lin.nonlinearity ≈  0   atol=1e-12

figure()
plot(x, y,".")
plot(x, lin.y_fit)
ax = twinx()
hlines(lin.nonlinearity, x[1], x[end])


# simplest test
lin = linearity(x, y, Normal)
@test lin.nonlinearity ≈  zeros(length(x))    atol=1e-12

figure()
plot(x, y,".")
plot(x, lin.y_fit)
ax = twinx()
plot(x,lin.nonlinearity)




end