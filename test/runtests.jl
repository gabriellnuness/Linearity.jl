using Test
using Linearity
using PyPlot




close("all")
@testset "Ideal nonlienarity test" begin

# nonlinearity zero
x = [1,2,3,4,5,6]
y = x


# default test
lin = nonlinearity(x, y)
figure()
plot(x, y,".")
plot(x, lin.y_fit)
ax = twinx()
ax.plot(x,lin.nonlinearity,color="tab:red")
title(L"Default: $\frac{x-x_{fit}}{x[end] - x[1]}$")
@test lin.nonlinearity ≈ zeros(length(x))   atol=1e-15

# rms test
lin = nonlinearity(x, y, RMS)
figure()
plot(x, y,".")
plot(x, lin.y_fit)
ax = twinx()
ax.hlines(lin.nonlinearity,x[1],x[end],color="tab:red")
title(L"RMS: $\sqrt{\frac{1}{N}\sum_{n=1}^{N}{(y-y_{fit})^2}}$")
@test lin.nonlinearity ≈  0   atol=1e-15

# simplest test
lin = nonlinearity(x, y, Simple)
figure()
plot(x, y,".")
plot(x, lin.y_fit)
ax = twinx()
ax.plot(x,lin.nonlinearity,color="tab:red")
title(L"Simple: $\frac{y-y_{fit}}{y_{fit}}$")
@test lin.nonlinearity ≈  zeros(length(x))    atol=1e-15

end






@testset "Definite nonlienarity test" begin

# nonlinearity zero
x = [0,1,2,3,4,5,6]
y = [0.001, 1.5, 2, 2.5, 4.5, 5, 6.3]

# default test
lin = nonlinearity(x, y)
figure()
plot(x, y,".")
plot(x, lin.y_fit)
ax = twinx()
ax.plot(x,lin.nonlinearity,color="tab:red")
title(L"Default: $\frac{x-x_{fit}}{x[end] - x[1]}$")
# @test lin.nonlinearity ≈ zeros(length(x))   atol=1e-12

# rms test
lin = nonlinearity(x, y, RMS)
figure()
plot(x, y,".")
plot(x, lin.y_fit)
ax = twinx()
ax.hlines(lin.nonlinearity,x[1],x[end],color="tab:red")
title(L"RMS: $\sqrt{\frac{1}{N}\sum_{n=1}^{N}{(y-y_{fit})^2}}$")
# @test lin.nonlinearity ≈  0   atol=1e-12

# simplest test
lin = nonlinearity(x, y, Simple)
figure()
plot(x, y,".")
plot(x, lin.y_fit)
ax = twinx()
ax.plot(x,lin.nonlinearity,color="tab:red")
title(L"Simple: $\frac{y-y_{fit}}{y_{fit}}$")
# @test lin.nonlinearity ≈  zeros(length(x))    atol=1e-12

end







@testset "Random tests" begin

# Random tests
x = sort(100 .* rand(1000) .- 50)
y = sort(100 .* rand(1000) .- 50)

lin = nonlinearity(x, y)
figure()
plot(x, y,".")
plot(x, lin.y_fit)
ax = twinx()
ax.plot(x,lin.nonlinearity,color="tab:red")
title(L"Default: $\frac{x-x_{fit}}{x[end] - x[1]}$")

lin = nonlinearity(x,y, Simple)
figure()
plot(x, y,".")
plot(x, lin.y_fit)
ax = twinx()
ax.plot(x,lin.nonlinearity,color="tab:red")
title(L"Simple: $\frac{y-y_{fit}}{y_{fit}}$")

lin = nonlinearity(x,y, RMS)
figure()
plot(x, y,".")
plot(x, lin.y_fit)
ax = twinx()
ax.hlines(lin.nonlinearity,x[1],x[end], color="tab:red")
title(L"RMS: $\sqrt{\frac{1}{N}\sum_{n=1}^{N}{(y-y_{fit})^2}}$")


end








