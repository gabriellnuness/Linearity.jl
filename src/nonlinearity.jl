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
    Relative nonlinearity with respect to the best fitted line

Method considers the difference in y compared to the fit.
However, the there is a singularity for values near zero.
"""
function nonlinearity(x, y, ::Type{Simple})

    (x_fit,y_fit, u) = linear_fit(x,y)
    nonlinearity = (y .- y_fit) ./ y_fit
        
    return (nonlinearity=nonlinearity, ang_coef=u[1], offset=u[2], x_fit=x_fit, y_fit=y_fit)
end
