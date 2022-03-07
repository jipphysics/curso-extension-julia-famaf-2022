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

# ╔═╡ 25847940-7157-11eb-05ec-9ff39a0d2b1f
using Plots, FileIO, PlutoUI, LsqFit

# ╔═╡ 88da7686-71eb-11eb-109b-85911cdccad4
md"Este archivo es para generar ejemplos de datos para fitear en el otro archivo: Cuadrados_minimos.jl. Hay que guardarlos en el git y luego se bajan desde el otro programa.
"

# ╔═╡ f864af02-7156-11eb-11c6-83358dc460f1
begin
	#t = (1 .+rand(1000)).*100
	t = 100:0.1:200
	T = [sin(2*π*tt/13 + 1.2) for tt ∈ t]# 0:0.1:100]
	T = T + 0.1 .*randn(length(T))
	scatter(t,T)
	tide = [t T]'
end

# ╔═╡ 243f5470-71f6-11eb-0ecd-49290597f562
md" Si queremos guardar los datos a un archivo descomentamos la siguiente linea"

# ╔═╡ 42fc7900-7157-11eb-18f7-c50130e84352
save("tide_data.jld2", "tide", tide)

# ╔═╡ e42037cc-7157-11eb-00cf-49ddb28dd6de
begin
	@. model(t,p) = p[1]*sin(p[2]*2*π*t + p[3])
	#p = zeros(3)
end

# ╔═╡ 2f38e6fa-7158-11eb-0fc3-8b3a88022040
@bind p1 Slider(0:0.02:2; default = 1, show_value=true)

# ╔═╡ c4189f24-7158-11eb-0148-4becacf59012
@bind p2 Slider(0:0.001:0.2; default = 1/13, show_value=true)

# ╔═╡ c418f8c6-7158-11eb-032f-530ea17d7d20
@bind p3 Slider(0:0.01:2π; default = 1.2, show_value=true)

# ╔═╡ bc7f0d38-7157-11eb-0e52-57c6f5400e88
begin
	xt = tide[1,:]
	yt = tide[2,:]
	scatter(xt,yt, alpha = 0.5; label="raw_data", xlabel="xt", ylabel="yt",size=(1000,1000))
	plot!(xt,model(xt,[p1,p2,p3]), linewidth=3, label="exact")
	fit = curve_fit(model, xt, yt, [1,1/13,1.2])
	plot!(xt,model(xt,fit.param), linewidth=2, label="best_fit", color="red")
	#fit.param
end

# ╔═╡ 5068cad2-715f-11eb-2228-13a4b0eb2c0a
fit.param

# ╔═╡ dceecaf8-737e-11eb-14fa-fd3f911aa47c
varinfo(PlutoUI)

# ╔═╡ f7027804-737e-11eb-167f-439825d67a7d
with_terminal(println, "Hola")

# ╔═╡ Cell order:
# ╟─88da7686-71eb-11eb-109b-85911cdccad4
# ╠═25847940-7157-11eb-05ec-9ff39a0d2b1f
# ╠═f864af02-7156-11eb-11c6-83358dc460f1
# ╟─243f5470-71f6-11eb-0ecd-49290597f562
# ╠═42fc7900-7157-11eb-18f7-c50130e84352
# ╠═bc7f0d38-7157-11eb-0e52-57c6f5400e88
# ╠═5068cad2-715f-11eb-2228-13a4b0eb2c0a
# ╠═e42037cc-7157-11eb-00cf-49ddb28dd6de
# ╠═2f38e6fa-7158-11eb-0fc3-8b3a88022040
# ╠═c4189f24-7158-11eb-0148-4becacf59012
# ╠═c418f8c6-7158-11eb-032f-530ea17d7d20
# ╠═dceecaf8-737e-11eb-14fa-fd3f911aa47c
# ╠═f7027804-737e-11eb-167f-439825d67a7d
