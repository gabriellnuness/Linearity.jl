# Linearity.jl

[![CI](https://github.com/gabriellnuness/Linearity.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/gabriellnuness/Linearity.jl/actions/workflows/ci.yml)

## Example

```julia
using Linearity
using DelimitedFiles
using PyPlot

y = readdlm("example/read_data_example.txt")
x = -69:1:71

lin = nonlinearity(x, y)

figure()
plot(x, y, ".")
plot(x, lin.y_fit, color="white")
    xlabel("input [°/s]")
    ylabel("output [°/s]")
ax = twinx()
ax.plot(x, lin.nonlinearity*1e6, color="tab:red", alpha=.8)
ax.set_ylabel("Nonlinearity wrt dynamic range [ppm]")
```

![image](doc/ex_default.svg)
![image](doc/ex_simple.svg)
![image](doc/ex_rms.svg)
