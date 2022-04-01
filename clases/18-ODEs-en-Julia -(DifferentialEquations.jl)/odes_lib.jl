"md 
Librería con algunos integradores de Runge-Kutta.

"


"""
    ODEproblem(Method, f, y0, intervalo, N) 

Hace una evolución de una ecuación ordindaria dada por f(y,t) usando Method.
    Method: algún método de integración, por ejemplo Euler(f,y0,t0,h)
    f = función que nos da la tangente como en (y,t)
    y0 = y inicial
    intervalo = (t_inicial, t_final)
    N = número de pasos

# Examples
```julia-repl
julia> 
function f(y,t)
    return -y + sin(2π*t)
end

y0 = 0.0
intervalo = (0,1)
t, y = ODEproblem(Euler, f, y0, intervalo, 101)
```
"""
function ODEproblem(Method,f,y0::AbstractArray,intervalo,N)
    (a,b) = intervalo
    h = (b-a)/(N-1)
    t = zeros(N)
    y = fill(y0[1],(length(y0),N))
    t[1] = a
    y[:,1] = y0
    for i in 2:N
        t[i] = t[i-1] + h
        y[:,i] = Method(f,y[:,i-1],t[i-1],h)         
    end
    return (t[:],y[:,:])
end

function ODEproblem(Method,f,y0::AbstractArray,intervalo,N,p)
    (a,b) = intervalo
    h = (b-a)/(N-1)
    t = zeros(N)
    y = fill(y0[1],(length(y0),N)) #zeros((length(y0),N))
    t[1] = a
    y[:,1] = y0
    for i in 2:N
        t[i] = t[i-1] + h
        y[:,i] = Method(f,y[:,i-1],t[i-1],h,p)         
    end
    return (t[:],y[:,:])
end

"""
    Euler(f,y0,t0,h)

Hace un paso del método de Euler explícito: 
    f = función que nos da la tangente como en (y,t,p)
    y0 = y inicial
    t0 = t inicial
    h = dt

# Examples
```julia-repl
julia> 
function f(y,t)
    return -y + sin(2π*t)
end
h= 0.1
Euler(f,1,0,h)
0.9
```
"""
function Euler(f,y0,t0,h)
    return y0 + h*f(y0,t0)
end

"""
    Euler(f,y0,t0,h,p)

Hace un paso del método de Euler explícito: 
    f = función que nos da la tangente como en (y,t,p)
    y0 = y inicial
    t0 = t inicial
    h = dt
    p = parametros opcionales.

# Examples
```julia-repl
julia> 
function f(y,t,p)
    return -p[1]*y + sin(2π*t) + p[2]
end
h= 0.1
Euler(f,1,0,h,[1,2])
1.1
```
"""
function Euler(f,y0,t0,h,p)
    return y0 + h*f(y0,t0,p)
end


"""
    RK2(f,y0,t0,h,p...)

Hace un paso del método de Runge-Kutta a punto intermedio: 
    f = función que nos da la tangente como en (y,t)
    y0 = y inicial
    t0 = t inicial
    h = dt

# Examples
```julia-repl
julia> 
function f(y,t)
    return -y + sin(2π*t)
end
h= 0.1
RK2(f,1,0,h)
0.9
```
"""
function RK2(f,y0,t0,h)
    y1 = y0 + 0.5*h*f(y0,t0)
    return y0 + h*f(y1,t0+0.5*h)
end
function RK2(f,y0,t0,h,p)
    y1 = y0 + 0.5*h*f(y0,t0,p)
    return y0 + h*f(y1,t0+0.5*h,p)
end

"""
    RK4(f,y0,t0,h,p...)

Hace un paso del método del metodo clásico de RK de orden 4: 
    f = función que nos da la tangente como en (y,t)
    y0 = y inicial
    t0 = t inicial
    h = dt
    p = extra parameters

# Examples
```julia-repl
julia> 
function f(y,t)
    return -y + sin(2π*t)
end
h= 0.1
RK4(f,1,0,h)
0.9342307485981525
```
"""
function RK4(f,y0,t0,h)
    k1 = h*f(y0,t0)
    k2 = h*f(y0+0.5*k1, t0+0.5*h)
    k3 = h*f(y0+0.5*k2, t0+0.5*h)
    k4 = h*f(y0+k3, t0+h)
    return y0 + (k1 + 2k2 + 2k3 + k4)/6
end
function RK4(f,y0,t0,h,p)
    k1 = h*f(y0,t0,p)
    k2 = h*f(y0+0.5*k1, t0+0.5*h,p)
    k3 = h*f(y0+0.5*k2, t0+0.5*h,p)
    k4 = h*f(y0+k3, t0+h,p)
    return y0 + (k1 + 2k2 + 2k3 + k4)/6
end

