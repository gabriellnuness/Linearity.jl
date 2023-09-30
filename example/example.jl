using Linearity
using DelimitedFiles
using PyPlot

y = readdlm("example/read_data_example.txt")
x = -69:1:71

lin = nonlinearity(x,y)

figure()
plot(x,y,".")
plot(x,lin.y_fit,color="white")
    xlabel("input [°/s]")
    ylabel("output [°/s]")
ax = twinx()
ax.plot(x, lin.nonlinearity*1e6,color="tab:red",alpha=.8)
    ax.set_ylabel("Nonlinearity wrt dynamic range [ppm]")



lin = nonlinearity(x,y,Simple)

figure()
plot(x,y,".")
plot(x,lin.y_fit,color="white")
    xlabel("input [°/s]")
    ylabel("output [°/s]")
ax = twinx()
ax.plot(x, lin.nonlinearity*1e6, color="tab:red",alpha=.8)
    ax.set_ylabel("Nonlinearity wrt best fit [ppm]")
    ax.set_ylim(-20,20)
    


lin = nonlinearity(x,y,RMS)

figure()
plot(x,y,".")
plot(x,lin.y_fit,color="white")
    xlabel("input [°/s]")
    ylabel("output [°/s]")
ax = twinx()
ax.plot(x, lin.nonlinearity/(maximum(x)-minimum(x))*1e6*ones(length(x)), color="tab:red",alpha=.8)
    ax.set_ylabel("Nonlinearity RMS \nwrt to dynamic range [ppm]")
    ax.set_yticks([lin.nonlinearity/(maximum(x)-minimum(x))*1e6])
    ax.spines["right"].set_visible(true)