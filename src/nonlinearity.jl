"""
    Relative nonlinearity
"""
function linearity(x, y)

    A = [x ones(length(x))] 
    u = (A'*A)\A'*y

    y_fit = @. u[1]*x + u[2]
    x_fit = @. (y - u[2]) / u[1]

    nonlinearity =  (x .- x_fit) / (maximum(x) - minimum(x))

    return (nonlinearity=nonlinearity, ang_coef=u[1], offset=u[2], x_fit=x_fit, y_fit=y_fit)
end


function linearity(x, y, ::Type{RMS})

    A = [x ones(length(x))] 
    u = (A'*A)\A'*y

    y_fit = @. u[1]*x + u[2]
    x_fit = @. (y - u[2]) / u[1]

    dynamic_range_output = maximum(y) - minimum(y)
    
    nonlinearity = sum((y .- y_fit).^2 / (length(y))) / dynamic_range_output # rms
        
    return (nonlinearity=nonlinearity, ang_coef=u[1], offset=u[2], x_fit=x_fit, y_fit=y_fit)
end

function linearity(x, y, ::Type{Normal})

    A = [x ones(length(x))] 
    u = (A'*A)\A'*y

    y_fit = @. u[1]*x + u[2]
    x_fit = @. (y - u[2]) / u[1]
  
    nonlinearity = (y .- y_fit) ./ y_fit
        
    return (nonlinearity=nonlinearity, ang_coef=u[1], offset=u[2], x_fit=x_fit, y_fit=y_fit)
end


