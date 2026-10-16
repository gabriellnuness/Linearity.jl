using Linearity
using DelimitedFiles
using PyPlot
using Random

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

# plotting the RMS error makes no sense because it provides a single value

# figure()
# plot(x,y,".")
# plot(x,lin.y_fit,color="white")
#     xlabel("input [°/s]")
#     ylabel("output [°/s]")
# ax = twinx()
# ax.plot(x, 3*lin.nonlinearity/(maximum(x)-minimum(x))*1e6*ones(length(x)), color="tab:red",alpha=.8)
# 	ax.set_ylabel("Nonlinearity RMS \nwrt to dynamic range [ppm]")
# 	ax.set_yticks([lin.nonlinearity/(maximum(x)-minimum(x))*1e6])
# 	ax.spines["right"].set_visible(true)



lin = nonlinearity(x, y, Sigma3)
lin.nonlinearity * 1e6    # 3σ in ppm of FS




"""
	Comparing all methods with different number of points used to fit the line

	Sweep the number of points used in the fit (k = 2 ... N) and plot the
	nonlinearity error [ppm of full scale] against k.

	method = nothing  -> default: peak of the error wrt dynamic range
	method = Simple   -> peak of the error wrt best fit (unstable near zero)
	method = RMS      -> RMS of the residuals / span
	method = Sigma3   -> 3σ / span (k = 2 is NaN, needs k ≥ 3)

	Three curves are produced:
		1. evenly spaced subset, error evaluated on the subset points
		2. random subsets (first and last always included), min–max band
		3. evenly spaced subset fit, error evaluated on ALL points
"""
function sweep_nonlinearity(x, y; method = nothing, ntrials = 200, makeplot = true)

	# sort by setpoint and make plain vectors
	xv = collect(float.(vec(x)))
	yv = collect(float.(vec(y)))
	p  = sortperm(xv)
	xv = xv[p]
	yv = yv[p]

	N  = length(xv)
	FS = maximum(xv) - minimum(xv)

	# call the package method, reducing the result to a single number [ppm]
	function err_subset(idx)
		xs, ys = xv[idx], yv[idx]
		if method === nothing
			return maximum(abs.(nonlinearity(xs, ys).nonlinearity)) * 1e6
		elseif method === Simple
			return maximum(abs.(nonlinearity(xs, ys, Simple).nonlinearity)) * 1e6
		elseif method === RMS
			return nonlinearity(xs, ys, RMS).nonlinearity / (maximum(xs) - minimum(xs)) * 1e6
		elseif method === Sigma3
			return length(idx) > 2 ? nonlinearity(xs, ys, Sigma3).nonlinearity * 1e6 : NaN
		else
			error("method must be nothing, Simple, RMS or Sigma3")
		end
	end

	# fit on idx, same metric evaluated on ALL points (out of sample)
	function err_all(idx)
		(_, _, u) = Linearity.linear_fit(xv[idx], yv[idx])
		y_fit = @. u[1] * xv + u[2]
		r_in  = (yv .- y_fit) ./ abs(u[1])          # input-referred residual
		if method === nothing
			return maximum(abs.(r_in)) / FS * 1e6
		elseif method === Simple
			return maximum(abs.((yv .- y_fit) ./ y_fit)) * 1e6
		elseif method === RMS
			return sqrt(sum(abs2, yv .- y_fit) / N) / FS * 1e6
		else # Sigma3
			return length(idx) > 2 ? 3 * sqrt(sum(abs2, r_in) / N) / FS * 1e6 : NaN
		end
	end

	ks       = collect(2:N)
	even_sub = zeros(length(ks))
	even_all = zeros(length(ks))
	rnd_min  = zeros(length(ks))
	rnd_max  = zeros(length(ks))

	for (j, k) in enumerate(ks)
		# 1) evenly spaced indices, first and last included
		idx = unique(round.(Int, range(1, N, length = k)))
		even_sub[j] = err_subset(idx)
		even_all[j] = err_all(idx)

		# 2) random subsets with first and last fixed
		vals = Float64[]
		for _ in 1:ntrials
			mid = k > 2 ? randperm(N - 2)[1:k-2] .+ 1 : Int[]
			push!(vals, err_subset(sort([1; mid; N])))
		end
		rnd_min[j], rnd_max[j] = extrema(vals)
	end

	# plot (default color cycle)
	ylab = method === nothing ? "max nonlinearity wrt dynamic range [ppm]" :
		   method === Simple  ? "max nonlinearity wrt best fit [ppm]" :
		   method === RMS     ? "RMS nonlinearity wrt dynamic range [ppm]" :
								"3σ nonlinearity wrt dynamic range [ppm]"

	figure(figsize = (9, 5))
	fill_between(ks, rnd_min, rnd_max, alpha = 0.2,
				 label = "random subsets (min–max)")
	plot(ks, even_sub, lw = 2,
		 label = "evenly spaced points")
	plot(ks, even_all, lw = 2, ls = "--",
		 label = "fit on subset, error on all points")
	xlabel("number of measurement points")
	ylabel("nonlinearity error [ppm]")
	title(method === nothing ? "peak, wrt dynamic range" :
		  method === Simple  ? "peak, wrt best fit" :
		  method === RMS     ? "RMS, wrt dynamic range" :
							   "3σ, wrt dynamic range")
	legend()
	grid(true, alpha = 0.3)
	tight_layout()

	return (k = ks, even_sub = even_sub, even_all = even_all,
			rnd_min = rnd_min, rnd_max = rnd_max)
end


res_default = sweep_nonlinearity(x, y)
res_simple  = sweep_nonlinearity(x, y; method = Simple)
res_rms     = sweep_nonlinearity(x, y; method = RMS)
res_sigma3  = sweep_nonlinearity(x, y; method = Sigma3)



"""
	Compare all methods in one figure: nonlinearity error [ppm] vs number of
	evenly spaced points used for the fit and the error calculation.

	`simple_floor`: for `Simple`, points where |y_fit| is below this fraction of
	the maximum |y_fit| are ignored, to avoid the singularity near zero output.
"""
function sweep_compare(x, y; simple_floor = 0.05)

	xv = collect(float.(vec(x)))
	yv = collect(float.(vec(y)))
	p  = sortperm(xv)
	xv = xv[p]
	yv = yv[p]
	N  = length(xv)

	ks = collect(3:N)
	e_default = zeros(length(ks))
	e_simple  = zeros(length(ks))
	e_rms     = zeros(length(ks))
	e_sigma3  = zeros(length(ks))

	for (j, k) in enumerate(ks)
		idx  = unique(round.(Int, range(1, N, length = k)))
		xs, ys = xv[idx], yv[idx]
		span = maximum(xs) - minimum(xs)

		# default: peak of the error wrt dynamic range
		e_default[j] = maximum(abs.(nonlinearity(xs, ys).nonlinearity)) * 1e6

		# Simple: peak error wrt best fit, ignoring points near zero output
		ls   = nonlinearity(xs, ys, Simple)
		mask = abs.(ls.y_fit) .> simple_floor * maximum(abs.(ls.y_fit))
		e_simple[j] = maximum(abs.(ls.nonlinearity[mask])) * 1e6

		# RMS (1σ) wrt dynamic range
		e_rms[j] = nonlinearity(xs, ys, RMS).nonlinearity / span * 1e6

		# 3σ wrt dynamic range
		e_sigma3[j] = nonlinearity(xs, ys, Sigma3).nonlinearity * 1e6
	end

	custom_plot_colors =   ["#6bc7f2"
							"#fd5679"
							"#f3bc6b"
							"#6cd776"
							"#8c564b"
							"#bcbd22"
							"#7f7f7f"
							"#e377c2"]

	figure(figsize=(5.5,4))
	plot(ks, e_default, color=custom_plot_colors[1], label = "peak, wrt dynamic range")
	# plot(ks, e_simple, label = "peak, wrt best fit")
	plot(ks, e_rms, color=custom_plot_colors[2], label = "RMS (1σ), wrt dynamic range")
	plot(ks, e_sigma3, color=custom_plot_colors[3], label = "3σ, wrt dynamic range")
	# yscale("log")
	xlabel("number of measurement points")
	ylabel("nonlinearity error [ppm]")
	legend()
	grid(true, alpha = 0.3, which = "both")

	return (k = ks, default = e_default, simple = e_simple, rms = e_rms, sigma3 = e_sigma3)
end


res_all = sweep_compare(x, y)
show()