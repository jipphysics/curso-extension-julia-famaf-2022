a = 0.5
b = 2

if a > 1
    println("Hola")
elseif a == 1
    println("Chau")
elseif a < 1
    println("otra cosa")
else
    println("Que hago?")
end

println("ya termina el programa")

a > b

2 > 1

typeof(2>1)



>(3,2)

@code_llvm(>(1,2))

true * 5

false * 5

using Pkg
Pkg.add("Plots")
using Plots

x0 = 0
f(x) = -(x < x0)*x^2 + (x >= x0)*x^2
plot(f)

true && true # and

false || false # or

!true

f(x) = 2.0*((x >= 0) && (x <=1))

plot(f)

function g(x)
    if x >= 0 && x <= 1 return 1
    else return 0
    end
end

plot(g)


