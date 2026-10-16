"""
    Linear fit by least squares
"""
function linear_fit(x,y)

    A = [x ones(length(x))] 
    u = (A'*A)\A'*y

    y_fit = @. u[1]*x + u[2]
    x_fit = @. (y - u[2]) / u[1]

    return (x_fit, y_fit, u)
end



"""
    Relative nonlinearity with respect to dynamic range
""" 
function nonlinearity(x, y)

    (x_fit,y_fit, u) = linear_fit(x,y)
    nonlinearity =  (x .- x_fit) / (maximum(x) - minimum(x))
    
    return (nonlinearity=nonlinearity, ang_coef=u[1], offset=u[2], x_fit=x_fit, y_fit=y_fit)
end



"""
    Residue absolute value from the fitting line
"""
function nonlinearity(x, y, ::Type{RMS})

    (x_fit,y_fit, u) = linear_fit(x,y)
    nonlinearity = sqrt(1/length(y) * sum((y .- y_fit).^2))
        
    return (nonlinearity=nonlinearity, ang_coef=u[1], offset=u[2], x_fit=x_fit, y_fit=y_fit)
end



"""
    nonlinearity(x, y, ::Type{Sigma3})

3σ nonlinearity as a fraction of the input span (multiply by `1e6` for ppm).

Uses the `RMS` method, converted to input-referred (divided by `|slope|`),
unbiased (`N/(N-2)` instead of `1/N`) and scaled by 3. Requires at least 3 points.

Independent of the sensor gain and corrects the small-sample bias of `RMS`.

!!! warning
    A datasheet σ may be the spread of the fit residuals (what this computes) or the
    spread across units, and datasheets rarely say which. Check the definition before comparing.

Returns `(nonlinearity, ang_coef, offset, x_fit, y_fit)`.
"""
function nonlinearity(x, y, ::Type{Sigma3})

    N = length(y)
    N > 2 || throw(ArgumentError("3sigma needs at least 3 points"))

    rms = nonlinearity(x, y, RMS)                   # 1sigma biased (1/N), in units of y
    sigma_in = rms.nonlinearity * sqrt(N / (N - 2)) / abs(rms.ang_coef)   # unbiased, in units of x
    nl = 3sigma_in / (maximum(x) - minimum(x))

    return (nonlinearity=nl, ang_coef=rms.ang_coef, offset=rms.offset,
            x_fit=rms.x_fit, y_fit=rms.y_fit)
end



"""
    Relative nonlinearity with respect to the best fitted line

Method considers the difference in y compared to the fit.
However, the there is a singularity for values near zero.
"""
function nonlinearity(x, y, ::Type{Simple})

    (x_fit,y_fit, u) = linear_fit(x,y)
    nonlinearity = (y .- y_fit) ./ y_fit
        
    return (nonlinearity=nonlinearity, ang_coef=u[1], offset=u[2], x_fit=x_fit, y_fit=y_fit)
end
