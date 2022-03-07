### A Pluto.jl notebook ###
# v0.14.7

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ b0f07f70-709d-11eb-18c4-c3e18fe313b2
using Statistics, Plots, LsqFit, PlutoUI, LinearAlgebra, FileIO

# ╔═╡ b20f440a-70b5-11eb-39f3-c7722d706c17
md"# Modelado de datos: *'Cuadrados mínimos'*, *'Ajuste por funciones'*

Es la base de la ciencia de datos.

[Aquí](https://drive.google.com/file/d/1E7Ou-wZtm4tuEnSKbMLmEY3HzXk8DUhv/view?usp=sharing) pueden encontrar un video explicativo"

# ╔═╡ aa6199e4-f426-433a-ba1b-a1df01a9bf28
TableOfContents(title="📚 Contenido", indent=true, depth=4, aside=true)

# ╔═╡ 96d389ac-711f-11eb-1ecc-b5539d6495cb
md"Dada dos series de datos, $\{x_i\}$ y $\{y_i\}$, queremos encontrar si hay una relación entre ellos. Comenzaremos con el caso donde se busca una relación lineal.
$y_i = a_1 + a_2 * x_i$. A modo de ejemplo contruiremos los datos empleando la relación lineal con parámetros dados sumandoles una componente pequeña aleatoria.
La componente aleatoria tiene media de cero y $\sigma = 1$.

$$y_i = a_1 + a_2 * x_i + \epsilon Rand$$
Para corroborar esto último graficamos su histograma.
Para la variable independiente tomamos un conjunto equiespaciados de puntos.
"

# ╔═╡ fe4f6088-709d-11eb-2e70-bf9c04887219
begin
	ϵ = 0.1
	a1 = 1.
	a2 = 2.
	xdata = range(1, stop=3, length=200)
	ydata = a1 .+ a2 .* xdata+ ϵ * randn(length(xdata))
	histogram(randn(length(xdata))
		#,size=(600,600)
	)
end

# ╔═╡ 63a3a450-e541-4fc7-9f30-807614669afd
md"Ploteamos ahora los datos propuestos."

# ╔═╡ 26958b94-709e-11eb-193c-abd32211f111
scatter(xdata,ydata, alpha = 0.5, frame_style=:origin, label="data points", leg=:topleft, xlabel="xdata", ylabel="ydata"
	#,size=(800,800)
)

# ╔═╡ 928b9abb-b0c7-4d11-af75-29094f86ba21
md"Sumamos al gráfico la función exacta por comparación."

# ╔═╡ dbae23a6-709e-11eb-255c-6b246a1d82d9
begin
	scatter(xdata,ydata, alpha = 0.5, frame_style=:origin, label="data points", leg=:topleft, xlabel="xdata", ylabel="ydata")
	plot!(xdata, a1 .+ a2 .* xdata, linewidth = 4,
		label="ajustados"
		#,size=(800,800)
		)	
end

# ╔═╡ 1e3c30cc-7122-11eb-12b0-3b2aa0953ac2
md"## Encontrando los parámetros"

# ╔═╡ 239adf24-7121-11eb-1db9-df285eef255c
md"La idea ahora es reencontrar los parámetros $(a1,a2)$ a partir de los dados, $(xdata,ydata)$. Para simplificar la búsqueda de estos parámetros eliminamos uno de ellos trasladando los datos de manera que los promedios de ambos datos sean nulos. 
Es decir, definimos nuevos datos como $xdata_0 = xdata - <xdata>$, etc. Donde $<>$ significa tomar el promedio. De esa forma, en las nuevas variables la relación será del tipo $y_i = a_2 x_i$. Luego de encontrar $a_2$ es simple reconstituir las variables originales y obtener $a_1$ usando la igualdad con los promedios."

# ╔═╡ a05cabe0-70a0-11eb-3a6f-13a03b009f10
begin
	
		x_s = xdata .- sum(xdata)/length(xdata)
		y_s = ydata .- sum(ydata)/length(ydata)
		scatter(x_s,y_s, alpha = 0.5, frame_style=:origin, label="data points", leg=:topleft, xlabel="xdata", ylabel="ydata")
		plot!(x_s, a2 .* x_s, linewidth = 4
		,label="ajuste"
		#,size=(800,800)
	)
end

# ╔═╡ 280d122c-7ddb-4894-bb0a-416479a7f3cf


# ╔═╡ 5f4db12c-a714-4a7f-a9fa-1c8d9f9e85ee
md"Utilizaremos tres formas de encontrar los parámetros en orden de sofisticación: "

# ╔═╡ 4c36082a-1f51-45d0-acb1-eb2db73b9ced
md"### Ajuste gráfico. 
Trazamos rectas que pasan por el origen con distintas pendientes y vemos cual aproxima mejor nuestros datos. Para ello generamos un Slider que nos da distintos valores para los parámetros.
"

# ╔═╡ 42ca4316-70a0-11eb-2bae-fbc5b3472332
@bind aa Slider(-1:0.2:4; default=2, show_value=true)

# ╔═╡ 77b6fb56-709f-11eb-3116-3fe183335bcc
begin
	scatter(x_s,y_s, alpha = 0.5, frame_style=:origin, label="data points", leg=:topleft, xlabel="xdata", ylabel="ydata")
	plot!(x_s, aa .* x_s, linewidth = 4
		#,size=(800,800)
		,label="ajuste"
	)
end

# ╔═╡ a39ffdd4-7122-11eb-30bd-13b8618ed938
md"### Ajuste analítico / gráfico.

Definimos una función distancia entre los puntos datos y distintas rectas y buscamos su mínimo. Para ello usamos la distancia Euclídea. Vemos a simple vista que el mínimo esta justamente para el valor del parámetro fijado en los datos. 
" 

# ╔═╡ 555d69bd-13d8-4902-a785-3d19a876c8cd
md"Para ello definimos una función distancia, la diferencia entre los puntos medidos y los obtenidos a partir del modelo."

# ╔═╡ 066ccf32-70a1-11eb-2264-c1d98968804f
function distance(a, x, y)
	return sqrt((y .- a .*x)'*(y .- a .*x))/length(x)
	#return sqrt(sum.((y .- a .*x).^2)) 
end

# ╔═╡ 4682e8e0-70a1-11eb-0963-078eee9410e4
distance(2, x_s, y_s);

# ╔═╡ 0c1f3ecd-80ad-4f55-998c-b35d2b0a61f3
begin
	r = range(-1., stop=2*a2, length = 200)
	s = [distance(x, x_s, y_s) for x ∈ r]
end

# ╔═╡ 69b258be-70a1-11eb-08bf-2bf580c6a1e8
begin
	plot(r,s
		,lw=3
		,label="función distancia"
		#,size=(1000,1000)
	)
end

# ╔═╡ 56c40a90-7123-11eb-33e3-09d683e8978b
md" Vemos a simple vista que el mínimo está cercano al valor 2. Usando la función findmin() podemos ajustar el resultado a un valor más preciso. Para ello evaluamos la función distancia en muchos puntos uniformente distribuidos del parámetro y buscamos el lugar donde el vector de estas cantidades es mínimo y con el encontramos el parámetro. " 

# ╔═╡ 9af192c8-711e-11eb-002f-df71037526be
r[findmin(s)[2]]

# ╔═╡ 2dba09b2-70a4-11eb-0cc4-c9c479db808a
md"### Ajuste Analítico.

Calculamos el mínimo de la función distancia.

Para mayor generalidad volvemos al problema original (sin trasladarlos). 
Dado los datos xdata y ydata tenemos una distancia, función de dos parámetros, $[p_1, p_2]$, 

$d(p_1,p_2)^2 = \sum_i (y_i - (p_1 + p_2 * x_i))^2$

Esta es una función cuadrática en $p_1$ y $p_2$, y por lo tanto suave. 
Usamos aquí el cuadrado de la distancia pues el mínimo coincide con el de su cuadrado y es más simple para trabajar, además es suave incluso cuando la distancia se anula. Su mínimo estará en el único punto donde su derivada se anula con respecto a cada uno de los parámetros:

$\partial_{p_1} d(p_1,p_2) = \partial_{p_2} d(p_1,p_2) = 0$

Desarrollando los cuadrados y sumando vemos que:

$$d(p_1,p_2)^2 = \sum_i [y_i^2 - 2 y_i (p_1 + p_2 * x_i) + (p_1 + p_2 * x_i)^2]$$

$$= \sum_i (y_i^2) + p_1^2 * N   - 2p_1 \sum_i y_i + 2p_1 p_2 \sum_i x_i + p_2^2 \sum_i x_i^2 - 2p_2\sum y_ix_i$$
$$= <y^2> + p_1(b*<1> - 2<y> + 2p_2<x>) + p_2(p_2 <x^2> - 2<xy>)$$,

donde, $<s> := \frac{1}{N}\sum_i^N s_i$.

Por lo tanto,

$$\partial_{p_1} d(p_1,p_2)^2 = 2p_1 - 2<y> + 2p_2 <x>$$


y 

$$\partial_{p_2} d(p_1,p_2)^2 = 2p_1 <x> + 2p_2<x^2> - 2<xy>$$.

Resolvemos el sistema $2 \times 2$ para $(p_1, p_2)$.

"



# ╔═╡ ce363d5b-cc20-4941-80fc-432f01647b06
md"Lo resolvemos usando la biblioteca de álgebra lineal de Julia"

# ╔═╡ dd12fc25-a074-4c8c-9dd1-ddaa643c235b
md"Probamos el algoritmo con el ejemplo anterior, pero permitimos que los parámetros varíen."

# ╔═╡ da4eacad-8f47-4ed8-87d7-4a174310dbd7
md"Cambiamos los parámetros con los que creamos el dato y vemos que los parámetros cambian de forma que el ajuste es nuevamente bueno."

# ╔═╡ 8d22abc2-70b1-11eb-0b52-2d05ad1ba312
@bind p2 Slider(-3:6; default = 2, show_value=true)

# ╔═╡ e9d629e0-70b1-11eb-213a-5d609433e4de
@bind p1 Slider(-2:4; default = 1, show_value=true)

# ╔═╡ d4756f70-f4bc-40c7-bccd-3dca4242b440
begin
	#ϵ = 0.1
	#p1 = 1.
	#p2 = 2.
	xdata_1 = range(1, stop=3, length=200)
	ydata_1 = p1 .+ p2 .* xdata+ ϵ * randn(length(xdata_1))
	#histogram(randn(length(xdata)))
end

# ╔═╡ ebfefe88-70a8-11eb-1969-a3ae75cf72cc
begin
	A = zeros(2,2)
	f = zeros(2)
	N = ones(length(xdata))
	A[1,1] = 1
	A[1,2] = xdata_1'*N / length(xdata_1)
	A[2,1] = A[1,2]
	A[2,2] = xdata_1'*xdata_1 / length(xdata_1)
	
	f[1] = ydata_1'*N  / length(xdata_1)
	f[2] = xdata_1'*ydata_1 / length(xdata_1)
end

# ╔═╡ ccc82b18-70b0-11eb-112d-a503d66b6b33
p = f' / A

# ╔═╡ 333cf37e-70b1-11eb-1616-63d971f03a66
begin
	scatter(xdata_1,ydata_1, alpha = 0.5, frame_style=:origin, label="data points", leg=:topleft, xlabel="xdata", ylabel="ydata")
	plot!(xdata_1, p[1].+ p[2].*xdata_1 ,  linewidth = 4
		,label="ajuste"
		#,size=(1000,1000)
	)
end

# ╔═╡ e0be0184-70b4-11eb-2025-091a431f9c07
e = sqrt(sum((ydata - p[1].*xdata .+ p[2]).^2))/length(xdata);

# ╔═╡ 2452d0fe-70b4-11eb-1682-fddd1a7dd41d
md" El error en la aproximación del ajuste de cuadrados mínimos se expresa como la distancia dividida por el número de puntos, es decir:

``
e = \frac{ \sqrt{\sum^N_i (y_i - (p_1 + p_2*x_i)^2)} }{N} = 
``
=$(e)
"

# ╔═╡ dc1955f0-f35b-46e5-8529-4c470670842b
md"!!! note 
Falta error en los parámetros!
"

# ╔═╡ 5d997418-70b5-11eb-05f9-37cd5c59276b
md"# Ajuste por funciones no lineales
Ahora vamos a emplear un paquete de Julia, **LsqFit**, para encontrar fiteos muy generales a conjuntos de datos. 

Primero repetiremos la cuenta con el fiteo lineal y luego veremos uno no lineal.

Para usar el paquete debemos definir un *modelo*, que es simplemente la función que proponemos para aproximar los datos, la cual dependerá de parámetros libres que iremos ajustando de acuerdo a los datos presentes. Además debemos dar algunos valores iniciales de estos parámetros. La distancia se va minimizando a partir de un algoritmo de minimización iterativo conocido como *Levenberg Marquardt*.

Para el caso lineal ya trabajado proponemos entonces: 
"

# ╔═╡ 095d3f68-709e-11eb-0e5c-d987f6a027e7
begin
	p0 = [0.5, 0.5]
	@. model(x, p) = p[1] + x*p[2]
end

# ╔═╡ 65605e72-70ca-11eb-2442-1b524e2a3be3
begin
	fit = curve_fit(model, xdata, ydata, p0);
	fit.param
end

# ╔═╡ 8357e8f8-7126-11eb-1853-19050526a4fe
md"Además de los parámetros encontrados la variable fit tiene más información, como por ejemplo la matriz de covarianza, la cual nos da un error estadístico para los parámetros. Para ver los significados de estas estimaciones de error es preciso conocer un poco más de estadística." 

# ╔═╡ 10167b44-70cb-11eb-18aa-cfb3b8bf7892
cov = estimate_covar(fit)

# ╔═╡ 346f04c0-70cb-11eb-3bd9-7ba4d985e0a2
#se = standard_error(fit)
#se = sqrt(cov)
sqrt(Diagonal(cov))

# ╔═╡ 70d205fc-70cb-11eb-1f96-4f1df265c5f5
margin_of_error = margin_error(fit, 0.1)

# ╔═╡ b02c7046-7127-11eb-34e6-0f3a88b50127
confidence_intervals = confidence_interval(fit, 0.1)

# ╔═╡ b3827416-70cd-11eb-0c47-5b98b59dd367
md"## Un caso no lineal"

# ╔═╡ cbe333c4-70cd-11eb-2b1a-31f730411017
begin
	@. model_nl(x, p) = p[1]*exp(x*p[2])
	#ydata_nl = zeros(length(xdata))
	ydata_nl = model_nl(xdata .+ ϵ .*rand(length(xdata)), [4.0, -2.0])  .+ 0.2 .* ϵ .*rand(length(xdata))
end

# ╔═╡ ef2e998e-70cf-11eb-0624-ad174268eeea
scatter(xdata, ydata_nl, alpha = 0.5, label="data points", leg=:topleft, xlabel="xdata", ylabel="ydata"
	#,size=(1000,1000)
)

# ╔═╡ 371abd68-70d0-11eb-2f08-1f554c7610e6
fit_nl = curve_fit(model_nl, xdata, ydata_nl, p0); fit_nl.param

# ╔═╡ 6d72f29a-70d0-11eb-14dd-3beaf78a77e1
begin
	scatter(xdata, ydata_nl, alpha = 0.5, label="data points", leg=:topleft, xlabel="xdata", ylabel="ydata")
	plot!(xdata, model_nl(xdata,fit_nl.param), linewidth = 3
		#,size=(1000,1000)
	)
end

# ╔═╡ 196d6940-70d1-11eb-1606-af5fbff749de
begin
	cov_nl = estimate_covar(fit_nl)
	se = sqrt(Diagonal(cov_nl))
end

# ╔═╡ 8e46004a-7128-11eb-3d15-f18f02ff47e2
md"## Ejercicio

Para este ejercicio mostramos primero como obtener datos de un archivo (previamente producido) con datos para hacer un ajuste.

!!! Note

Aquí usamos el formato propio de Julia, `JLD2`, que es muy conveniente. Si sus archivos están en el formato CSV (*Comma Separate Values*) puede usar la librería `CVS` como se indica más abajo.
"

# ╔═╡ 2df5f59c-7134-11eb-39c2-b753c2903d61
tide = load(download("https://gitlab.com/oreula/julia_examples/-/raw/master/Cuadrados_Min/tide_data.jld2"),"tide")

# ╔═╡ 65774492-7134-11eb-35c2-39817e784ae1
begin
	xt = tide[1,:]
	yt = tide[2,:]
	scatter(xt,yt
		#,size=(1000,1000)
	)
end

# ╔═╡ 8e2dca94-7140-11eb-23db-07081a2000eb
md"Use la librería ya introducida para proponer un modelo para estos datos y encuentre los parámetros correctos. Puede primero hacerlo moviendo manualmente los parámetros y graficando el modelo sobre los datos."

# ╔═╡ 54731b59-85e0-442a-b23b-47c99f0bebe3
md"
Para usar la librería CSV seleccione aquí $(@bind allow_csv CheckBox())"

# ╔═╡ 4cbd5d1a-d93a-451a-b5c6-0912991b1587
if allow_csv
using CSV #coma separated values
using DataFrames
#using Plots
url_1 = "https://raw.githubusercontent.com/reula/MetodosNumericos2021/main/Guias/mediciones1-c1-g6.dat"
url_2="https://gitlab.com/oreula/julia_examples/-/raw/master/Cuadrados_Min/mediciones1-c1-g6.dat"
a_1 = CSV.read(download(url_2), DataFrame, header=["x", "y"], delim=" ", ignorerepeated=true)
scatter(a_1.x,a_1.y)
plot!(a_1.x,a_1.y)
plot!(xlim=(0,0.1))
end

# ╔═╡ 01de4d62-0d47-4423-afd2-42abcec683db
md"## Malos ejemplos:

El método de ajuste funciona bien para casos donde la función distancia tiene pocos mínimos y ninguno cercano al mínimo absoluto (en el caso que no partamos muy lejos de ella).

Ahora veremos un ejemplo donde las cosas no son tan lindas. Este es el ejemplo que está en: 

[Levenberg-Marquardt-Wikipedia](https://en.wikipedia.org/wiki/Levenberg%E2%80%93Marquardt_algorithm)

y se refiere al algorithmo usado por la librería, llamado **Levenberg-Marquardt**.
"

# ╔═╡ ebc60504-142c-48f6-a9d6-19745d78600c
md" Se trata de aproximar la función $ce(x) = a*cos(bx) + b*sin(ax)$ con $a=100$ y $b=102$"

# ╔═╡ 4cd57c56-f8d8-4558-b8e4-073c7c7ee710
ce(x,A,B) = A*cos(B*x) + B*sin(A*x)

# ╔═╡ 14be3370-bf92-4e61-95f0-431d10b6cd71
md"Aquí graficamos la función con una pequeña parturbación al azar."

# ╔═╡ 0bcf6839-4f65-4dd1-bf4d-10451b3d0a2b
begin
	x=0:0.01:100; y=ce.(x,100,102) + 0.01 *rand(length(x))
	#scatter(x,y)
	plot(x,y)
end

# ╔═╡ c74dbb79-3062-4a53-a83e-512ce9a026e9
md"Generamos el modelo y lo aplicamos:"

# ╔═╡ c83bb2a1-b0bd-4eca-a5f1-65b40c893be5
begin
	@. model_ce(x, p) = p[1]*cos(p[2]*x) + p[2]*sin(p[1]*x)
	pce = [90.; 90.]
	fit_ce = curve_fit(model_ce, x, y, pce); fit_ce.param
end

# ╔═╡ 48d7b13e-af57-403f-8573-845178285be3
begin
	cov_ce = estimate_covar(fit_ce)
	se_ce = sqrt(Diagonal(cov_ce))
end

# ╔═╡ 2ae0962e-dcbf-4861-8cf7-58e3a399943b
md"Vemos que el algoritmo encuentra un ajuste totalmente distinto! Y demás nos dice que es bueno! Ha encontrado otro mínimo."

# ╔═╡ caf89481-80f3-471d-9e1d-d9c02ff28551
begin
	xce = 0:0.1:10
	plot(x[1:100],y[1:100],label="Exacta")
	plot!(x[1:100],model_ce(x[1:100],fit_ce.param),label="Ajuste")
end

# ╔═╡ 6168aa5b-b294-4573-aacd-3f5073d195c6
md" Para comprender el problema graficamos la función distancia para este caso:
(usamos una función distancia normalizada con los datos a los propósitos de los gráficos)"

# ╔═╡ dc978b95-5dbd-4530-bc06-62bd11eed368
	d_ce(p1,p2) = sqrt(sum((y - model_ce(x, [p1;p2])).^2))/sqrt(sum(y.^2))

# ╔═╡ d7135bba-42a4-47c8-b9c3-2d19d8622464
begin
	begin
	p_ce_1f = 60:0.1:110;
	p_ce_2f = 60:0.1:110;
end
	#levels = 1.:0.01:1.3
	#heatmap(p_ce_1f, p_ce_2f, d_ce
	contour(p_ce_1f, p_ce_2f, d_ce
		, fill = true
		, levels = 20
		, c = cgrad(:beach)
		#,contour_labels = true
	)
end

# ╔═╡ cca37f6f-7811-45cd-92ff-65bb18692da6
md"Para ver las imágenes que siguen seleccione aquí $(@bind allow_run CheckBox())
tenga en cuenta que los cálculos necesarios son pesados"

# ╔═╡ 1ea85398-a498-423f-8cff-4962496168c9
if allow_run
@bind init_par Slider(1:100; default = 98, show_value=true)
end

# ╔═╡ b953e14a-f966-484a-a572-546bf28c0fbf
if allow_run
@bind final_par Slider(100.1:110; default = 104, show_value=true)
end

# ╔═╡ 02179573-efde-49a7-bb78-248ffcfb4649
if allow_run
	p_ce_1 = init_par:(final_par-init_par)/50:final_par;
	#p_ce_2 = init_par:1.:final_par;
	p_ce_2 = init_par:(final_par-init_par)/50:final_par;
end

# ╔═╡ 9a56a29d-5408-47af-814a-9ab27db1c200
if allow_run
	#levels = 1.:0.01:1.3
	contour(p_ce_1, p_ce_2, d_ce
		, fill = true
		, levels = 10
		, c = cgrad(:beach)
		#,contour_labels = true
	)
end

# ╔═╡ 92f836b0-c1f0-4a96-8131-f8a20790183b
md" Vemos que el problema es que hay cañadones muy estrechos con mínimos locales. El algoritmo para pues llega a condiciones que corresponden a mínimos locales." 

# ╔═╡ 5c84c0fe-887e-40fe-aff5-bed7789c22ef
begin
	allow_run_hm=false
	if allow_run_hm
		#levels = 1.:0.01:1.3
		heatmap(p_ce_1, p_ce_2, d_ce
			#, fill = true
			#, levels = 10
			, c = cgrad(:beach)
			#,contour_labels = true
		)
	end
end

# ╔═╡ Cell order:
# ╟─b20f440a-70b5-11eb-39f3-c7722d706c17
# ╠═b0f07f70-709d-11eb-18c4-c3e18fe313b2
# ╟─aa6199e4-f426-433a-ba1b-a1df01a9bf28
# ╟─96d389ac-711f-11eb-1ecc-b5539d6495cb
# ╟─fe4f6088-709d-11eb-2e70-bf9c04887219
# ╟─63a3a450-e541-4fc7-9f30-807614669afd
# ╟─26958b94-709e-11eb-193c-abd32211f111
# ╟─928b9abb-b0c7-4d11-af75-29094f86ba21
# ╟─dbae23a6-709e-11eb-255c-6b246a1d82d9
# ╟─1e3c30cc-7122-11eb-12b0-3b2aa0953ac2
# ╟─239adf24-7121-11eb-1db9-df285eef255c
# ╟─a05cabe0-70a0-11eb-3a6f-13a03b009f10
# ╟─280d122c-7ddb-4894-bb0a-416479a7f3cf
# ╟─5f4db12c-a714-4a7f-a9fa-1c8d9f9e85ee
# ╟─4c36082a-1f51-45d0-acb1-eb2db73b9ced
# ╟─77b6fb56-709f-11eb-3116-3fe183335bcc
# ╟─42ca4316-70a0-11eb-2bae-fbc5b3472332
# ╟─a39ffdd4-7122-11eb-30bd-13b8618ed938
# ╟─555d69bd-13d8-4902-a785-3d19a876c8cd
# ╠═066ccf32-70a1-11eb-2264-c1d98968804f
# ╟─4682e8e0-70a1-11eb-0963-078eee9410e4
# ╟─69b258be-70a1-11eb-08bf-2bf580c6a1e8
# ╠═0c1f3ecd-80ad-4f55-998c-b35d2b0a61f3
# ╟─56c40a90-7123-11eb-33e3-09d683e8978b
# ╠═9af192c8-711e-11eb-002f-df71037526be
# ╟─2dba09b2-70a4-11eb-0cc4-c9c479db808a
# ╠═ebfefe88-70a8-11eb-1969-a3ae75cf72cc
# ╟─ce363d5b-cc20-4941-80fc-432f01647b06
# ╠═ccc82b18-70b0-11eb-112d-a503d66b6b33
# ╟─dd12fc25-a074-4c8c-9dd1-ddaa643c235b
# ╟─d4756f70-f4bc-40c7-bccd-3dca4242b440
# ╠═333cf37e-70b1-11eb-1616-63d971f03a66
# ╟─da4eacad-8f47-4ed8-87d7-4a174310dbd7
# ╟─8d22abc2-70b1-11eb-0b52-2d05ad1ba312
# ╟─e9d629e0-70b1-11eb-213a-5d609433e4de
# ╟─2452d0fe-70b4-11eb-1682-fddd1a7dd41d
# ╠═e0be0184-70b4-11eb-2025-091a431f9c07
# ╟─dc1955f0-f35b-46e5-8529-4c470670842b
# ╟─5d997418-70b5-11eb-05f9-37cd5c59276b
# ╠═095d3f68-709e-11eb-0e5c-d987f6a027e7
# ╠═65605e72-70ca-11eb-2442-1b524e2a3be3
# ╟─8357e8f8-7126-11eb-1853-19050526a4fe
# ╠═10167b44-70cb-11eb-18aa-cfb3b8bf7892
# ╠═346f04c0-70cb-11eb-3bd9-7ba4d985e0a2
# ╠═70d205fc-70cb-11eb-1f96-4f1df265c5f5
# ╠═b02c7046-7127-11eb-34e6-0f3a88b50127
# ╟─b3827416-70cd-11eb-0c47-5b98b59dd367
# ╠═cbe333c4-70cd-11eb-2b1a-31f730411017
# ╟─ef2e998e-70cf-11eb-0624-ad174268eeea
# ╠═371abd68-70d0-11eb-2f08-1f554c7610e6
# ╟─6d72f29a-70d0-11eb-14dd-3beaf78a77e1
# ╠═196d6940-70d1-11eb-1606-af5fbff749de
# ╟─8e46004a-7128-11eb-3d15-f18f02ff47e2
# ╠═2df5f59c-7134-11eb-39c2-b753c2903d61
# ╟─65774492-7134-11eb-35c2-39817e784ae1
# ╟─8e2dca94-7140-11eb-23db-07081a2000eb
# ╟─54731b59-85e0-442a-b23b-47c99f0bebe3
# ╠═4cbd5d1a-d93a-451a-b5c6-0912991b1587
# ╟─01de4d62-0d47-4423-afd2-42abcec683db
# ╟─ebc60504-142c-48f6-a9d6-19745d78600c
# ╠═4cd57c56-f8d8-4558-b8e4-073c7c7ee710
# ╠═14be3370-bf92-4e61-95f0-431d10b6cd71
# ╠═0bcf6839-4f65-4dd1-bf4d-10451b3d0a2b
# ╟─c74dbb79-3062-4a53-a83e-512ce9a026e9
# ╠═c83bb2a1-b0bd-4eca-a5f1-65b40c893be5
# ╠═48d7b13e-af57-403f-8573-845178285be3
# ╟─2ae0962e-dcbf-4861-8cf7-58e3a399943b
# ╟─caf89481-80f3-471d-9e1d-d9c02ff28551
# ╟─6168aa5b-b294-4573-aacd-3f5073d195c6
# ╠═dc978b95-5dbd-4530-bc06-62bd11eed368
# ╠═d7135bba-42a4-47c8-b9c3-2d19d8622464
# ╟─cca37f6f-7811-45cd-92ff-65bb18692da6
# ╟─1ea85398-a498-423f-8cff-4962496168c9
# ╟─b953e14a-f966-484a-a572-546bf28c0fbf
# ╟─02179573-efde-49a7-bb78-248ffcfb4649
# ╟─9a56a29d-5408-47af-814a-9ab27db1c200
# ╟─92f836b0-c1f0-4a96-8131-f8a20790183b
# ╟─5c84c0fe-887e-40fe-aff5-bed7789c22ef
