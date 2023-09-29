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
    Relative nonlinearity
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
    Simplest nonlinearity calculation

Method considers the difference in y compared to the fit.
However, the there is a singularity for values near zero.
"""
function nonlinearity(x, y, ::Type{Simple})

    (x_fit,y_fit, u) = linear_fit(x,y)
  
    nonlinearity = (y .- y_fit) ./ y_fit
        
    return (nonlinearity=nonlinearity, ang_coef=u[1], offset=u[2], x_fit=x_fit, y_fit=y_fit)
end


"""
    Take the mean of `y` for unique `x` values

This function performs the mean for periodic signals.
Instead of staying in a fixed input value for a long time (steps) in order to 
reduce the random noise, we assume that the signal passes multiple times for the same point
multiple times and we take the mean.
"""
function mean_unique_vals(x, y, dig)
    ind_sort = sortperm(x)
    x = round.(x,digits=dig)
    x = x[ind_sort]
    y = y[ind_sort]

    x_unique = unique(x)
    ind_unique = indexin(x_unique,x)
    y_mean = zeros(length(x_unique))
    y_std = zeros(length(x_unique))
    for i in 1:length(x_unique)
        if i == length(x_unique)
            y_mean[i] = y[ind_unique[i]]
            y_std[i] = 0.0
        else
            y_mean[i] = mean(y[ind_unique[i]:ind_unique[i+1]-1])
            y_std[i] = std(y[ind_unique[i]:ind_unique[i+1]-1])
        end
    end
    return (x_unique, y_mean, y_std)
end