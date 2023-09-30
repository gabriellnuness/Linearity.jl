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
    len_unique = length(x_unique)
    ind_unique = indexin(x_unique,x)
    y_mean = zeros(len_unique)
    y_std = zeros(len_unique)
    for i in 1:len_unique
        if i == len_unique
            y_mean[i] = y[ind_unique[i]]
            y_std[i] = 0.0
        else
            y_mean[i] = mean(y[ind_unique[i]:ind_unique[i+1]-1])
            y_std[i] = std(y[ind_unique[i]:ind_unique[i+1]-1])
        end
    end
    y_std = replace!(y_std, NaN=>0)
    return (x_unique, y_mean, y_std)
end