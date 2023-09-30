using Test
using Linearity
using PyPlot





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
x = sort(100 .* randn(1000) .- 50)
y = x .+ 0.01.*randn(1000)

lin = nonlinearity(x, y)
figure()
plot(x, y,".")
plot(x, lin.y_fit, color="black")
    title(L"Default: $\frac{x-x_{fit}}{x[end] - x[1]}$")
    ylabel("output")
    xlabel("input")
ax = twinx()
ax.plot(x,lin.nonlinearity*1e6,color="tab:red",alpha=.8)
    ax.spines["right"].set_visible(true)
    ax.set_ylabel("Error [ppm]", color="tab:red",alpha=.8)

lin = nonlinearity(x,y, Simple)
figure()
plot(x, y,".")
plot(x, lin.y_fit, color="black")
    ylabel("output")
    xlabel("input")
ax = twinx()
ax.plot(x,lin.nonlinearity*1e6,color="tab:red",alpha=.8)
    ax.spines["right"].set_visible(true)
    ax.set_ylabel("Error [ppm]", color="tab:red",alpha=.8)
    title(L"Simple: $\frac{y-y_{fit}}{y_{fit}}$")

lin = nonlinearity(x,y, RMS)
figure()
plot(x, y,".")
plot(x, lin.y_fit, color="black")
    ylabel("output")
    xlabel("input")
    title(L"RMS: $\sqrt{\frac{1}{N}\sum_{n=1}^{N}{(y-y_{fit})^2}}$")
ax = twinx()
ax.hlines(lin.nonlinearity,x[1],x[end], color="tab:red",alpha=.8)
    ax.spines["right"].set_visible(true)
    ax.set_ylabel("Error [output unit]", color="tab:red",alpha=.8)


end



@testset "Mean of unique values" begin
    
    # simplified version with already sorted x and y
    x = [1,1,  2, 3,  4,4,  5, 6, 7] 
    y = [1,2,  3, 4,  5,6,  7, 8, 9]
    # should restult in the following
    x_res = [1, 2, 3, 4, 5, 6, 7]
    y_res = [1.5, 3, 4, 5.5, 7, 8, 9]
    y_std = [√2/2,0,0,√2/2,0,0,0]

    (x_unique, y_mean, y_std) = mean_unique_vals(x,y,1)
    @test x_unique == Float32.(x_res)
    @test y_mean == Float32.(y_res)
    @test y_std ≈ Float32.(y_std)


    # out of order test
    x = [1,1,  4,4,  5, 6, 7, 2, 3] 
    y = [1,2,  5,6,  7, 8, 9, 3, 4]

    (x_unique, y_mean, y_std) = mean_unique_vals(x,y,1)
    @test x_unique == Float32.(x_res)
    @test y_mean == Float32.(y_res)
    @test y_std ≈ Float32.(y_std)


end




@testset "Mean values before nonlinearity" begin
    
    # simplified version with already sorted x and y
    x = [1,1,  2, 3,  4,4,  5, 6, 7]
    y = [1,2,  3, 4,  5,6,  7, 8, 9]

    lin = nonlinearity(x,y)
    close("all")  
    figure()
    plot(x, y,".")
    plot(x, lin.y_fit)
    ax = twinx()
    ax.plot(x,lin.nonlinearity,color="tab:red",alpha=.2)
    
    (x_unique, y_mean, y_std) = mean_unique_vals(x,y,3)

    # linearity with mean values
    lin = nonlinearity(x_unique,y_mean)
    figure()
    errorbar(x_unique, y_mean,y_std, fmt=".")
    plot(x_unique, lin.y_fit)
    ax = twinx()
    ax.plot(x_unique,lin.nonlinearity,color="tab:red",alpha=.2)


    ## Sine wave simulation
    t = 1:0.01:1000
    x = @. 10*sin(2π*1*t)
    noise = 0.8
    y = x .+ noise*rand(length(x)) .- noise*rand(length(x))

    figure()
    plot(t,x)
    plot(t,y)

    lin = nonlinearity(x,y)
    figure()
    plot(x, y,".")
    plot(x, lin.y_fit)
    ax = twinx()
    ax.plot(x,lin.nonlinearity*100,color="tab:red",alpha=.2)
    title("Default linearity")


    # just one cycle
    x_cut = x[1:100]
    y_cut = y[1:100]
    t_cut = t[1:100]

    figure()
    plot(t_cut,x_cut)
    plot(t_cut,y_cut)

    lin = nonlinearity(x_cut,y_cut)
    figure()
    plot(x_cut, y_cut,".")
    plot(x_cut, lin.y_fit)
    ax = twinx()
    ax.plot(x_cut,lin.nonlinearity*100,color="tab:red",alpha=.2)
    title("One cycle linearity")




    # linearity with mean values
    ind = sortperm(x)
    figure()
    plot(t,x[ind])
    plot(t,y[ind])

    (x_unique, y_mean, y_std) = mean_unique_vals(x,y,1)
    lin = nonlinearity(x_unique,y_mean)
    figure()
    errorbar(x_unique, y_mean,y_std, fmt=".")
    plot(x_unique, lin.y_fit)
    ax = twinx()
    ax.plot(x_unique,lin.nonlinearity*100,color="tab:red",alpha=.2)
    title("Mean values linearity") 

    
end
